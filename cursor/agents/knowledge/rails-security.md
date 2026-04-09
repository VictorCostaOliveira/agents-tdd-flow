# Security Checklist para Rails

## 1. Injection Attacks

### SQL Injection

```ruby
# 🚨 CRÍTICO: Vulnerável a SQL injection
User.where("email = '#{params[:email]}'")
User.where("name LIKE '%#{params[:name]}%'")
Post.order("#{params[:sort]} #{params[:direction]}")

# ✅ SEGURO: Usar placeholders
User.where("email = ?", params[:email])
User.where("name LIKE ?", "%#{params[:name]}%")
User.where(email: params[:email])  # Melhor ainda

# Para order/campos dinâmicos, whitelist:
ALLOWED_SORT = %w[created_at name email].freeze
sort = ALLOWED_SORT.include?(params[:sort]) ? params[:sort] : 'created_at'
User.order(sort)
```

### Command Injection

```ruby
# 🚨 CRÍTICO: Command injection
system("git log #{params[:branch]}")
`ls #{params[:directory]}`
exec("rm -rf #{params[:path]}")

# ✅ SEGURO: Usar arrays ou validar rigorosamente
system("git", "log", params[:branch])

# Ou validar input
raise unless params[:branch].match?(/\A[a-z0-9_\-\/]+\z/i)
system("git log #{params[:branch]}")
```

### NoSQL Injection (MongoDB, etc)

```ruby
# 🚨 CRÍTICO: NoSQL injection
User.where(email: params[:email])  # Se params[:email] = { $ne: "" }

# ✅ SEGURO: Sanitizar input
User.where(email: params[:email].to_s)
```

## 2. Authentication & Authorization

### Broken Authentication

```ruby
# 🚨 CRÍTICO: Senha em plain text
user.update(password: params[:password])

# ✅ SEGURO: has_secure_password
class User < ApplicationRecord
  has_secure_password
  validates :password, length: { minimum: 12 }, if: :password_digest_changed?
end

# 🚨 CRÍTICO: Token previsível
token = "reset_#{user.id}_#{Time.now.to_i}"
token = Digest::MD5.hexdigest(user.email)

# ✅ SEGURO: Token criptograficamente seguro
token = SecureRandom.urlsafe_base64(32)
token = SecureRandom.hex(32)

# 🚨 CRÍTICO: Session fixation
session[:user_id] = user.id  # Sem regenerar session ID

# ✅ SEGURO: Regenerar session
reset_session  # Limpa session antiga
session[:user_id] = user.id
```

### Broken Access Control (IDOR)

```ruby
# 🚨 CRÍTICO: Insecure Direct Object Reference
def show
  @document = Document.find(params[:id])  # Qualquer ID acessível
end

def update
  @post = Post.find(params[:id])
  @post.update(post_params)  # Sem verificar ownership
end

# ✅ SEGURO: Verificar ownership
def show
  @document = current_user.documents.find(params[:id])
end

def update
  @post = current_user.posts.find(params[:id])
  @post.update(post_params)
end

# Ou usar Pundit:
def update
  @post = Post.find(params[:id])
  authorize @post  # Verifica policy
  @post.update(post_params)
end

# 🚨 CRÍTICO: IDs sequenciais previsíveis
# URL: /users/123/invoices/456

# ✅ SEGURO: UUIDs ou hashids
# Migration:
add_column :invoices, :uuid, :string, null: false, index: { unique: true }
# Model:
before_create { self.uuid = SecureRandom.uuid }
# Controller:
@invoice = current_user.invoices.find_by!(uuid: params[:uuid])
```

### Mass Assignment

```ruby
# 🚨 CRÍTICO: Mass assignment
def create
  User.create(params[:user])  # Pode setar is_admin: true, role: 'admin'
end

# ✅ SEGURO: Strong parameters
def create
  User.create(user_params)
end

private

def user_params
  params.require(:user).permit(:name, :email, :password)
  # NUNCA permitir: :admin, :role, :is_admin, :password_digest
end

# Para admins com atributos especiais:
def user_params
  permitted = [:name, :email, :password]
  permitted << :role if current_user.super_admin?
  params.require(:user).permit(permitted)
end
```

## 3. Sensitive Data Exposure

```ruby
# 🚨 CRÍTICO: Expor dados sensíveis em API
def show
  render json: @user  # Expõe password_digest, tokens, etc
end

# ✅ SEGURO: Serialização explícita
def show
  render json: @user.as_json(only: [:id, :name, :email, :created_at])
end

# Ou usar serializer:
render json: UserSerializer.new(@user)

# 🚨 CRÍTICO: Logar dados sensíveis
Rails.logger.info "User #{user.email} logged in with password #{password}"
Rails.logger.debug "Credit card: #{params[:credit_card]}"

# ✅ SEGURO: Filtrar parâmetros sensíveis
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  :password, :password_confirmation,
  :token, :api_key, :secret,
  :ssn, :credit_card, :cvv,
  :auth_token, :access_token
]

# 🚨 CRÍTICO: Secrets hardcoded
STRIPE_KEY = "sk_live_abc123"
aws_secret = "AKIAIOSFODNN7EXAMPLE"

# ✅ SEGURO: Credentials ou ENV
stripe_key = Rails.application.credentials.stripe[:secret_key]
aws_secret = ENV['AWS_SECRET_ACCESS_KEY']

# 🚨 CRÍTICO: Dados sensíveis em URL/GET
link_to "Reset", reset_password_path(token: user.reset_token)

# ✅ SEGURO: POST ou hidden form
= form_with url: reset_password_path do |f|
  = f.hidden_field :token, value: user.reset_token
```

## 4. XSS (Cross-Site Scripting)

```ruby
# 🚨 CRÍTICO: HTML não escapado
<%= raw @user.bio %>
<%= @comment.html_safe %>
<%= sanitize @user.bio %>  # Sem restrições

# ✅ SEGURO: Escapar HTML (Rails faz por padrão)
<%= @user.bio %>  # Rails escapa automaticamente

# Para HTML confiável, restringir tags:
<%= sanitize @user.bio, 
    tags: %w[p br strong em a],
    attributes: %w[href] %>

# 🚨 CRÍTICO: JavaScript injection
<script>
  var username = '<%= @user.name %>';  # Se name = </script><script>alert(1)
</script>

# ✅ SEGURO: JSON encoding
<script>
  var username = <%= @user.name.to_json %>;
  var userData = <%= @user.to_json %>;
</script>
```

## 5. CSRF (Cross-Site Request Forgery)

```ruby
# 🚨 CRÍTICO: CSRF desabilitado
class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session  # Em web controllers!
end

# ✅ SEGURO: CSRF habilitado
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

# Para APIs (sem session):
class Api::BaseController < ActionController::API
  # Token authentication (JWT, API keys)
  before_action :authenticate_token
end
```

## 6. Security Misconfiguration

```ruby
# 🚨 CRÍTICO: CORS aberto
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'  # PERIGOSO!
    resource '*', headers: :any, methods: :any
  end
end

# ✅ SEGURO: CORS restrito
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://meuapp.com', 'https://www.meuapp.com'
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete],
      credentials: true
  end
end

# 🚨 CRÍTICO: Debug em produção
config.consider_all_requests_local = true  # production.rb
config.action_controller.perform_caching = false

# ✅ SEGURO: Configuração apropriada
# production.rb
config.consider_all_requests_local = false
config.action_controller.perform_caching = true
config.log_level = :info  # Não :debug
```

## 7. XXE (XML External Entities)

```ruby
# 🚨 CRÍTICO: Parse XML sem proteção
doc = Nokogiri::XML(params[:xml])

# ✅ SEGURO: Desabilitar entidades externas
doc = Nokogiri::XML(params[:xml]) do |config|
  config.nonet.noent
end
```

## 8. Deserialization

```ruby
# 🚨 CRÍTICO: Deserializar dados não confiáveis
data = Marshal.load(params[:data])
config = YAML.load(params[:config])

# ✅ SEGURO: JSON ou safe_load
data = JSON.parse(params[:data])
config = YAML.safe_load(
  params[:config],
  permitted_classes: [Symbol, Date, Time],
  permitted_symbols: [],
  aliases: false
)
```

## 9. Rate Limiting & DOS

```ruby
# 🚨 CRÍTICO: Sem rate limiting
def create
  User.create!(user_params)  # Abuse possível
end

# ✅ SEGURO: Rate limiting com rack-attack
# config/initializers/rack_attack.rb
Rack::Attack.throttle('signup/ip', limit: 5, period: 1.hour) do |req|
  req.ip if req.path == '/signup' && req.post?
end

Rack::Attack.throttle('api/ip', limit: 300, period: 5.minutes) do |req|
  req.ip if req.path.start_with?('/api')
end

# Proteção contra scraping
Rack::Attack.throttle('search/ip', limit: 20, period: 1.minute) do |req|
  req.ip if req.path == '/search'
end
```

## 10. File Upload Vulnerabilities

```ruby
# 🚨 CRÍTICO: Upload sem validação
def create
  file = params[:file]
  File.write("public/uploads/#{file.original_filename}", file.read)
end

# ✅ SEGURO: Validar tipo, tamanho, nome
class Document < ApplicationRecord
  has_one_attached :file
  
  validates :file, attached: true,
                   content_type: ['application/pdf', 'image/png', 'image/jpg'],
                   size: { less_than: 10.megabytes }
end

# Sanitizar nome do arquivo
def sanitize_filename(filename)
  # Remove path e caracteres perigosos
  File.basename(filename).gsub(/[^\w\.\-]/, '_')
end

# Verificar conteúdo real (magic bytes)
def valid_image?(file)
  type = Marcel::MimeType.for(file)
  ['image/png', 'image/jpeg', 'image/gif'].include?(type)
end
```

## 11. Race Conditions

### Check-Then-Act (TOCTOU)

```ruby
# 🚨 CRÍTICO: TOCTOU em operações financeiras
def transfer(from_user, to_user, amount)
  if from_user.balance >= amount  # Check
    # Outro request pode gastar aqui!
    from_user.update!(balance: from_user.balance - amount)  # Act
    to_user.update!(balance: to_user.balance + amount)
  end
end

# ✅ SEGURO: Pessimistic locking
def transfer(from_user, to_user, amount)
  ActiveRecord::Base.transaction do
    from_user.lock!  # SELECT FOR UPDATE
    to_user.lock!
    
    if from_user.balance >= amount
      from_user.update!(balance: from_user.balance - amount)
      to_user.update!(balance: to_user.balance + amount)
    else
      raise InsufficientFundsError
    end
  end
end
```

### Database Concurrency

```ruby
# 🚨 CRÍTICO: Race em reserva de assentos
def reserve_seat(event_id)
  event = Event.find(event_id)
  if event.available_seats > 0
    event.update!(available_seats: event.available_seats - 1)
  end
end

# ✅ SEGURO: Operação atômica
def reserve_seat(event_id)
  Event.where(id: event_id)
       .where('available_seats > 0')
       .update_all('available_seats = available_seats - 1')
end

# Ou optimistic locking:
class Event < ApplicationRecord
  # Migration: add_column :events, :lock_version, :integer, default: 0
end

begin
  event.with_lock { event.decrement!(:available_seats) }
rescue ActiveRecord::StaleObjectError
  retry
end
```

### Counter Races

```ruby
# 🚨 CRÍTICO: Incremento não atômico
view_count = post.views
post.update(views: view_count + 1)

# ✅ SEGURO: Operação atômica
post.increment!(:views)
Post.update_counters(post_id, views: 1)
```

## 12. Logging & Monitoring

```ruby
# 🚨 CRÍTICO: Eventos de segurança não logados
def login
  if user.authenticate(params[:password])
    session[:user_id] = user.id
  end
end

# ✅ SEGURO: Logar eventos críticos
def login
  if user.authenticate(params[:password])
    Rails.logger.info "[SECURITY] Login success: user_id=#{user.id} ip=#{request.remote_ip}"
    session[:user_id] = user.id
  else
    Rails.logger.warn "[SECURITY] Login failed: email=#{params[:email]} ip=#{request.remote_ip}"
  end
end

# Logar mudanças críticas:
after_action :log_security_event, only: [:update_permissions, :change_role]

def log_security_event
  Rails.logger.warn "[SECURITY] Permission change: user_id=#{current_user.id} " \
                    "target=#{@target.id} action=#{action_name}"
end
```

## 13. Dependency Management

```bash
# 🚨 CRÍTICO: Gems desatualizadas
# Gemfile sem versões

# ✅ SEGURO: Verificar regularmente
bundle audit check --update
bundle outdated

# CI/CD: Adicionar ao pipeline
script:
  - bundle audit check
```

## Security Checklist

Ao revisar código Rails, SEMPRE verificar:

- [ ] **Injection**: SQL/Command/NoSQL injection em queries dinâmicas?
- [ ] **Auth**: has_secure_password, tokens seguros, session regeneration?
- [ ] **Authorization**: Ownership checks, Pundit/CanCanCan?
- [ ] **Mass Assignment**: Strong parameters configurados?
- [ ] **Data Exposure**: API não expõe dados sensíveis?
- [ ] **Logging**: Filter parameters configurado? Sem secrets em logs?
- [ ] **XSS**: HTML escapado, JSON encoding em JavaScript?
- [ ] **CSRF**: protect_from_forgery habilitado?
- [ ] **CORS**: Origins específicos, não wildcard?
- [ ] **Deserialization**: Não usa Marshal/YAML.load com input não confiável?
- [ ] **Rate Limiting**: Endpoints críticos protegidos?
- [ ] **File Upload**: Validação de tipo, tamanho, sanitização?
- [ ] **Race Conditions**: Operações atômicas, locks apropriados?
- [ ] **Dependencies**: bundle audit sem vulnerabilidades?
- [ ] **Secrets**: Credentials/ENV, não hardcoded?

## Perguntas Críticas de Segurança

1. "O que um atacante malicioso pode fazer com este endpoint?"
2. "Este input é validado e sanitizado?"
3. "Dados sensíveis podem vazar em logs/responses?"
4. "Há check de autorização (não só autenticação)?"
5. "O que acontece com 2 requests simultâneos?"
