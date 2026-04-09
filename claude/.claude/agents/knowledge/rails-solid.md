# SOLID Checklist para Rails

## Single Responsibility Principle (SRP)

### Sinais de Violação
- Controller com lógica de negócio (validações complexas, cálculos, integrações)
- Model com > 300 linhas ou múltiplas responsabilidades não relacionadas
- Método que faz múltiplas coisas (valida + processa + notifica + log)
- Classe que muda por múltiplas razões diferentes

### Pergunta Chave
**"Qual é a ÚNICA razão pela qual esta classe/método mudaria?"**

### Exemplos Rails

```ruby
# ❌ Violação: Controller faz tudo
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    
    # Validação de negócio
    if @order.total < 10
      flash[:error] = "Minimum order $10"
      return render :new
    end
    
    # Cálculo de desconto
    if current_user.premium?
      @order.discount = @order.total * 0.2
    end
    
    # Pagamento
    charge = Stripe::Charge.create(
      amount: @order.total_with_discount,
      customer: current_user.stripe_id
    )
    
    # Inventário
    @order.items.each do |item|
      product = Product.find(item.product_id)
      product.decrement!(:stock, item.quantity)
    end
    
    # Notificação
    OrderMailer.confirmation(@order).deliver_later
    
    # Analytics
    track_event('order_created', @order.id)
    
    redirect_to @order
  end
end

# ✅ Correto: Service Object
class OrdersController < ApplicationController
  def create
    result = Orders::CreateService.call(
      order_params: order_params,
      user: current_user
    )
    
    if result.success?
      redirect_to result.order, notice: 'Order created!'
    else
      @order = result.order
      flash.now[:error] = result.errors
      render :new
    end
  end
end

# Service com responsabilidade única
class Orders::CreateService
  def self.call(order_params:, user:)
    new(order_params, user).call
  end
  
  def initialize(order_params, user)
    @order_params = order_params
    @user = user
  end
  
  def call
    build_order
    return failure unless valid?
    
    ActiveRecord::Base.transaction do
      process_payment
      update_inventory
      save_order
      send_notifications
    end
    
    success
  rescue => e
    failure(e.message)
  end
  
  private
  
  def build_order
    @order = Order.new(@order_params.merge(user: @user))
  end
  
  def valid?
    Orders::Validator.new(@order).valid?
  end
  
  def process_payment
    @payment = Payments::ProcessService.call(@order)
  end
  
  # ...
end
```

## Open/Closed Principle (OCP)

### Sinais de Violação
- Case/if statements que crescem quando adiciona novos tipos
- Modificar código existente para adicionar nova feature
- Sem pontos de extensão (hooks, callbacks, strategies)

### Pergunta Chave
**"Posso adicionar novo comportamento SEM modificar código existente?"**

### Exemplos Rails

```ruby
# ❌ Violação: Adicionar novo tipo requer editar método
class NotificationService
  def send(user, message)
    case user.notification_preference
    when 'email'
      EmailNotifier.send(user.email, message)
    when 'sms'
      SmsNotifier.send(user.phone, message)
    when 'push'
      PushNotifier.send(user.device_token, message)
    # Adicionar Slack requer editar aqui
    # when 'slack'
    #   SlackNotifier.send(user.slack_id, message)
    end
  end
end

# ✅ Correto: Strategy Pattern com polimorfismo
class NotificationService
  def send(user, message)
    notifier = NotifierFactory.for(user)
    notifier.send(message)
  end
end

class NotifierFactory
  def self.for(user)
    "#{user.notification_preference.capitalize}Notifier".constantize.new(user)
  end
end

# Cada notifier implementa mesma interface
class EmailNotifier
  def initialize(user)
    @user = user
  end
  
  def send(message)
    # ...
  end
end

class SlackNotifier  # Novo tipo! Sem modificar código existente
  def initialize(user)
    @user = user
  end
  
  def send(message)
    # ...
  end
end
```

## Liskov Substitution Principle (LSP)

### Sinais de Violação
- Subclasse que lança exception para método da superclasse
- Subclasse que no-op método da superclasse
- Código que checa tipo concreto (`.is_a?`, `.kind_of?`)
- Subclasse que enfraquece precondições ou fortalece pós-condições

### Pergunta Chave
**"Posso substituir a classe pai pela filha sem quebrar o código cliente?"**

### Exemplos Rails

```ruby
# ❌ Violação: Subclasse quebra contrato
class User < ApplicationRecord
  def update_profile(attributes)
    update!(attributes)
  end
end

class AdminUser < User
  def update_profile(attributes)
    raise "Admins cannot update profile"  # Quebra expectativa!
  end
end

# Cliente quebra:
def update_user_profile(user, attrs)
  user.update_profile(attrs)  # Funciona com User, falha com AdminUser
end

# ✅ Correto: Respeitar contrato OU redesenhar hierarquia
# Opção 1: Permitir na subclasse
class AdminUser < User
  def update_profile(attributes)
    # Permite, mas adiciona audit log
    super
    AuditLog.create(user: self, action: 'profile_update')
  end
end

# Opção 2: Composição ao invés de herança
class User < ApplicationRecord
  def update_profile(attributes)
    return false unless can_update_profile?
    update!(attributes)
  end
  
  def can_update_profile?
    true
  end
end

class Admin < ApplicationRecord
  # Não herda de User
  belongs_to :user
  
  def can_update_profile?
    false
  end
end
```

## Interface Segregation Principle (ISP)

### Sinais de Violação
- Concern com 20+ métodos que nem todos usam
- Classes que implementam métodos vazios ou com `raise NotImplementedError`
- Dependencies amplas quando só usa 1-2 métodos

### Pergunta Chave
**"Todos os includers deste concern usam TODOS os métodos?"**

### Exemplos Rails

```ruby
# ❌ Violação: Concern muito amplo
module Trackable
  def track_view; end
  def track_click; end
  def track_purchase; end
  def track_signup; end
  def track_login; end
  def track_logout; end
  def track_share; end
  def track_download; end
  def track_impression; end
  # ... 15 métodos mais
end

class Product < ApplicationRecord
  include Trackable  # Só usa track_view e track_purchase
end

# ✅ Correto: Concerns segregados
module ViewTrackable
  def track_view
    # ...
  end
end

module PurchaseTrackable
  def track_purchase
    # ...
  end
end

class Product < ApplicationRecord
  include ViewTrackable
  include PurchaseTrackable
end
```

## Dependency Inversion Principle (DIP)

### Sinais de Violação
- Lógica de negócio instancia classes de infraestrutura diretamente
- Hard-coded dependencies (Twilio, Stripe, AWS, etc)
- Import chains que acoplam business logic a IO/network/storage

### Pergunta Chave
**"Posso trocar a implementação sem mudar a lógica de negócio?"**

### Exemplos Rails

```ruby
# ❌ Violação: Acoplado a implementação concreta
class Order < ApplicationRecord
  after_create :notify_customer
  
  def notify_customer
    TwilioClient.send_sms(
      to: user.phone,
      body: "Order #{id} confirmed"
    )
  end
end

# Não consigo testar sem Twilio
# Não consigo trocar para Slack sem mudar Order

# ✅ Correto: Depender de abstração
class Order < ApplicationRecord
  after_create :notify_customer
  
  def notify_customer
    NotificationService.send(
      recipient: user,
      message: order_confirmation_message
    )
  end
  
  private
  
  def order_confirmation_message
    "Order #{id} confirmed"
  end
end

# NotificationService é abstração injetável
class NotificationService
  def self.send(recipient:, message:)
    notifier.send(recipient, message)
  end
  
  def self.notifier
    @notifier ||= Rails.configuration.notifier
  end
end

# Em config:
# config.notifier = SmsNotifier.new (produção)
# config.notifier = LogNotifier.new (desenvolvimento)
# config.notifier = MockNotifier.new (testes)
```

## Code Smells Rails-Specific

| Smell | Sinais | Solução |
|-------|--------|---------|
| **God Model** | Model > 300 linhas, callbacks em cascata, conhece todo domínio | Extrair Service Objects, Query Objects, Value Objects |
| **Fat Controller** | Controller > 100 linhas, lógica de negócio | Mover para Service Objects |
| **Callback Hell** | 5+ callbacks, callbacks que chamam callbacks | Service Object ou Event/Observer pattern |
| **Concerns Dumping Ground** | Concern > 200 linhas, baixa coesão | Reavaliar responsabilidades, criar abstrações específicas |
| **Primitive Obsession** | Strings/integers para conceitos de domínio | Value Objects (Money, Email, Phone, etc) |
| **Feature Envy** | Método usa mais dados de outra classe que da própria | Mover método para classe apropriada |
| **Long Parameter List** | Métodos com 4+ parâmetros | Parameter Object ou Builder pattern |
| **Shotgun Surgery** | Uma mudança requer editar 10+ arquivos | Melhorar encapsulamento e coesão |
| **Divergent Change** | Uma classe muda por múltiplas razões | Separar responsabilidades |

## Refactor Heuristics

1. **Dividir por responsabilidade, não por tamanho**
   - Arquivo pequeno pode violar SRP
   - Arquivo grande pode ser coeso

2. **Abstrair apenas quando necessário**
   - Espere o segundo caso de uso
   - Evite "Speculative Generality"

3. **Refatorar incrementalmente**
   - Isole comportamento antes de mover
   - Um refactor pequeno por vez

4. **Preservar comportamento primeiro**
   - Adicione testes ANTES de refatorar
   - Red-Green-Refactor

5. **Nomear pela intenção**
   - Se naming é difícil, abstração pode estar errada
   - Nomes revelam responsabilidades

6. **Preferir composição sobre herança**
   - Herança cria acoplamento forte
   - Composição é mais flexível

7. **Tornar estados ilegais irrepresentáveis**
   - Usar tipos/validações para garantir invariantes
   - Fail fast no construction time

## Checklist SOLID

Ao revisar código Rails, pergunte:

- [ ] **SRP**: Cada classe tem uma única razão para mudar?
- [ ] **OCP**: Posso adicionar comportamento sem modificar código existente?
- [ ] **LSP**: Subclasses podem substituir superclasses sem quebrar?
- [ ] **ISP**: Interfaces/concerns são focados e não forçam métodos não usados?
- [ ] **DIP**: Lógica de negócio depende de abstrações, não implementações?
- [ ] Há God Models ou Fat Controllers?
- [ ] Callbacks estão sob controle (< 3 por model)?
- [ ] Service Objects são usados para lógica complexa?
- [ ] Value Objects representam conceitos de domínio?
