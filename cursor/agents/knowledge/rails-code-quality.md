# Code Quality Checklist para Rails

## 1. Error Handling

### Exceções Engolidas

```ruby
# ❌ Exceção engolida
def process_payment
  charge_customer
rescue => e
  logger.error e  # Log mas continua como se tivesse sucesso
end

# ✅ Correto: Re-raise ou retornar erro
def process_payment
  charge_customer
rescue PaymentGateway::Error => e
  logger.error "Payment failed: #{e.message}"
  raise PaymentFailed, "Unable to process payment: #{e.message}"
end

# Ou retornar Result object:
def process_payment
  charge_customer
  Result.success
rescue PaymentGateway::Error => e
  Result.failure(e.message)
end
```

### Catch Muito Amplo

```ruby
# ❌ Catch muito genérico
begin
  process_order
rescue Exception => e  # Captura TUDO, incluindo SystemExit, SignalException
  logger.error e
end

rescue => e  # Implicitamente StandardError, mas ainda muito amplo

# ✅ Correto: Catch específico
begin
  process_order
rescue ActiveRecord::RecordInvalid => e
  # Handle validation errors
rescue PaymentError => e
  # Handle payment errors
rescue ShippingError => e
  # Handle shipping errors
end

# Ou criar exception hierarchy:
class OrderError < StandardError; end
class PaymentError < OrderError; end
class ShippingError < OrderError; end

rescue OrderError => e
  # Handle all order-related errors
```

### Missing Error Boundaries

```ruby
# ❌ Sem error handling
def update
  @user.update!(user_params)
  redirect_to @user
end

# ✅ Correto: Error boundary
def update
  @user.update!(user_params)
  redirect_to @user, notice: 'Updated successfully'
rescue ActiveRecord::RecordInvalid => e
  flash.now[:error] = e.message
  render :edit, status: :unprocessable_entity
end
```

### Async Errors

```ruby
# ❌ Erro assíncrono não tratado
class ProcessJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)
    process(user)  # Se falhar, erro silencioso
  end
end

# ✅ Correto: Rescue e notificar
class ProcessJob < ApplicationJob
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  def perform(user_id)
    user = User.find(user_id)
    process(user)
  rescue => e
    ErrorTracker.notify(e, user_id: user_id)
    raise  # Re-raise para Sidekiq retry
  end
end
```

## 2. Performance

### CPU-Intensive em Hot Path

```ruby
# ❌ Operação pesada no request
def show
  @stats = calculate_complex_statistics  # 5 segundos
  @report = generate_pdf_report  # 10 segundos
end

# ✅ Correto: Background job ou cache
def show
  @stats = Rails.cache.fetch("stats/#{params[:id]}", expires_in: 1.hour) do
    calculate_complex_statistics
  end
  
  # PDF em background
  if @report.pending?
    ReportGenerationJob.perform_later(params[:id])
  end
end
```

### Unbounded Loops

```ruby
# ❌ Loop sem limite
def process_all
  loop do
    item = fetch_next_item
    break unless item
    process(item)
  end
end

# ✅ Correto: Com timeout e batch limit
def process_all
  start_time = Time.current
  count = 0
  max_items = 1000
  
  loop do
    break if count >= max_items
    break if Time.current - start_time > 5.minutes
    
    item = fetch_next_item
    break unless item
    
    process(item)
    count += 1
  end
end
```

### Missing Cache

```ruby
# ❌ Cálculo caro executado toda vez
def dashboard
  @total_revenue = Order.sum(:amount)
  @user_count = User.count
  @active_users = User.where('last_seen_at > ?', 24.hours.ago).count
end

# ✅ Correto: Cache
def dashboard
  @total_revenue = Rails.cache.fetch('metrics/revenue', expires_in: 10.minutes) do
    Order.sum(:amount)
  end
  
  @user_count = Rails.cache.fetch('metrics/users', expires_in: 1.hour) do
    User.count
  end
end
```

### Unbounded Memory

```ruby
# ❌ Carrega tudo em memória
def export_csv
  @users = User.all  # 1 milhão de users na RAM
  CSV.generate do |csv|
    @users.each { |u| csv << [u.id, u.name] }
  end
end

# ✅ Correto: Streaming
def export_csv
  headers['X-Accel-Buffering'] = 'no'
  headers['Cache-Control'] = 'no-cache'
  headers['Content-Type'] = 'text/csv'
  headers['Content-Disposition'] = 'attachment; filename="users.csv"'
  
  self.response_body = Enumerator.new do |yielder|
    User.find_each do |user|
      yielder << "#{user.id},#{user.name}\n"
    end
  end
end
```

## 3. Boundary Conditions

### Nil/Undefined Handling

```ruby
# ❌ Não trata nil
def process(items)
  items.each { |i| i.process }  # Explode se items = nil
end

def display_name(user)
  user.first_name + ' ' + user.last_name  # Explode se nil
end

# ✅ Correto: Safe navigation e defaults
def process(items)
  return if items.blank?
  items.each { |i| i.process }
end

def display_name(user)
  return 'Guest' unless user
  [user.first_name, user.last_name].compact.join(' ').presence || 'Anonymous'
end

# Ou usar safe navigation:
user&.first_name || 'Guest'
```

### Empty Collections

```ruby
# ❌ Assume collection não-vazia
def show_first_item(items)
  items.first.display  # Explode se empty
end

# ✅ Correto: Verificar empty
def show_first_item(items)
  return 'No items' if items.empty?
  items.first.display
end
```

### Off-by-One

```ruby
# ❌ Off-by-one em paginação
def paginate(page, per_page = 10)
  offset = page * per_page  # Página 1 começa em offset 10!
  User.limit(per_page).offset(offset)
end

# ✅ Correto
def paginate(page, per_page = 10)
  offset = (page - 1) * per_page  # Página 1 = offset 0
  User.limit(per_page).offset(offset)
end

# Ou usar Kaminari/Pagy:
User.page(params[:page]).per(10)
```

### Numeric Boundaries

```ruby
# ❌ Sem validação de range
def set_discount(percentage)
  @discount = percentage  # E se for 150%? -10%?
end

def paginate(page)
  User.page(page)  # E se page = -1? 9999999?
end

# ✅ Correto: Validar ranges
def set_discount(percentage)
  raise ArgumentError, "Invalid percentage" unless (0..100).cover?(percentage)
  @discount = percentage
end

def paginate(page)
  page = [[page.to_i, 1].max, 1000].min  # Clamp entre 1-1000
  User.page(page)
end

# Em models:
validates :discount, numericality: { 
  greater_than_or_equal_to: 0,
  less_than_or_equal_to: 100
}
```

### Date/Time Edge Cases

```ruby
# ❌ Não considera timezone
def today_orders
  Order.where('created_at >= ?', Date.today)  # Qual timezone?
end

# ✅ Correto: Usar timezone
def today_orders
  Order.where('created_at >= ?', Time.current.beginning_of_day)
end

# ❌ Não valida date format
date = Date.parse(params[:date])  # Pode lançar exception

# ✅ Correto: Validar
begin
  date = Date.parse(params[:date])
rescue ArgumentError
  date = Date.today
end
```

## 4. Code Structure

### Métodos Grandes

```ruby
# ❌ Método muito grande (> 15 linhas)
def process_order
  # validação - 5 linhas
  # cálculo de preço - 10 linhas
  # pagamento - 15 linhas
  # email - 5 linhas
  # log - 3 linhas
  # Total: 38 linhas!
end

# ✅ Correto: Dividir responsabilidades
def process_order
  validate_order
  calculate_totals
  process_payment
  send_notifications
  log_completion
end

private

def validate_order
  # 5 linhas
end

def calculate_totals
  # 10 linhas
end
# ...
```

### DRY (Don't Repeat Yourself)

```ruby
# ❌ Duplicação
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    @order.user = current_user
    @order.tax = @order.subtotal * 0.1
    @order.total = @order.subtotal + @order.tax
    @order.save
  end
  
  def update
    @order = Order.find(params[:id])
    @order.assign_attributes(order_params)
    @order.tax = @order.subtotal * 0.1
    @order.total = @order.subtotal + @order.tax
    @order.save
  end
end

# ✅ Correto: Extrair lógica comum
class OrdersController < ApplicationController
  def create
    @order = build_order
    @order.save
  end
  
  def update
    @order = find_order
    @order.assign_attributes(order_params)
    @order.save
  end
  
  private
  
  def build_order
    current_user.orders.new(order_params).tap do |order|
      order.calculate_totals
    end
  end
end

class Order < ApplicationRecord
  before_save :calculate_totals
  
  def calculate_totals
    self.tax = subtotal * tax_rate
    self.total = subtotal + tax
  end
end
```

### Naming

```ruby
# ❌ Nomes não descritivos
def calc(u, p)
  x = u.a * p
  y = x * 0.1
  x + y
end

# ✅ Correto: Nomes descritivos
def calculate_order_total(user, products)
  subtotal = calculate_subtotal(user, products)
  tax = calculate_tax(subtotal)
  subtotal + tax
end
```

## 5. Rails Best Practices

### Fat Models, Skinny Controllers

```ruby
# ❌ Lógica no controller
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    
    if @order.valid?
      @order.status = 'pending'
      @order.tax = @order.subtotal * 0.1
      @order.total = @order.subtotal + @order.tax
      
      if @order.save
        OrderMailer.confirmation(@order).deliver_later
        redirect_to @order
      end
    end
  end
end

# ✅ Correto: Lógica no model ou service
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    
    if @order.save
      redirect_to @order
    else
      render :new
    end
  end
end

class Order < ApplicationRecord
  before_validation :set_defaults
  before_save :calculate_totals
  after_commit :send_confirmation, on: :create
  
  private
  
  def set_defaults
    self.status ||= 'pending'
  end
  
  def calculate_totals
    self.tax = subtotal * tax_rate
    self.total = subtotal + tax
  end
  
  def send_confirmation
    OrderMailer.confirmation(self).deliver_later
  end
end
```

### Callbacks em Moderação

```ruby
# ❌ Callback hell
class User < ApplicationRecord
  after_create :send_welcome_email
  after_create :create_profile
  after_create :notify_admins
  after_create :track_signup
  after_create :sync_to_crm
  after_update :invalidate_cache
  after_update :notify_followers
  before_destroy :cancel_subscriptions
  # ...
end

# ✅ Correto: Service Object
class Users::RegistrationService
  def self.call(user_params)
    user = User.create!(user_params)
    
    WelcomeMailer.welcome(user).deliver_later
    Profiles::CreateService.call(user)
    AdminNotifier.new_user(user)
    Analytics.track('signup', user_id: user.id)
    CrmSync.sync_user(user)
    
    user
  end
end
```

## Checklist de Qualidade

- [ ] **Error Handling**: Sem exceções engolidas, catches específicos?
- [ ] **Performance**: Sem operações pesadas em hot paths?
- [ ] **Boundaries**: Nil, empty, numeric ranges tratados?
- [ ] **Métodos pequenos**: Todos < 15 linhas?
- [ ] **DRY**: Sem duplicação de código?
- [ ] **Naming**: Nomes descritivos e claros?
- [ ] **Callbacks**: Usados com moderação (< 3 por model)?
- [ ] **Service Objects**: Lógica complexa extraída?
- [ ] **Tests**: Casos edge cobertos?

## Perguntas de Qualidade

1. "Este código é fácil de entender para outro dev?"
2. "O que acontece se input for nil/empty/negativo?"
3. "Este método faz mais de uma coisa?"
4. "Há duplicação que posso eliminar?"
5. "Os nomes revelam intenção claramente?"
