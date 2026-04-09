# Scalability Checklist para Rails

## 1. N+1 Queries

### Detectar N+1

```ruby
# 🚨 CRÍTICO: N+1 query
def index
  @posts = Post.all
end

# View:
<% @posts.each do |post| %>
  <%= post.author.name %>  # 1 query por post!
  <%= post.comments.count %>  # 1 query por post!
<% end %>

# ✅ SEGURO: Eager loading
def index
  @posts = Post.includes(:author).all
  # Ou com múltiplas associations:
  @posts = Post.includes(:author, :comments).all
end

# Para nested associations:
@posts = Post.includes(comments: :author).all
```

### includes vs preload vs eager_load

```ruby
# preload: Sempre usa 2+ queries separadas
Post.preload(:author)
# SELECT * FROM posts
# SELECT * FROM users WHERE id IN (1, 2, 3...)

# eager_load: Sempre usa LEFT OUTER JOIN
Post.eager_load(:author)
# SELECT posts.*, users.* FROM posts LEFT OUTER JOIN users...

# includes: Rails escolhe automaticamente
Post.includes(:author)
# Usa preload por padrão, eager_load se tiver WHERE na association

# Quando usar cada um:
# - includes: Default, deixa Rails decidir
# - preload: Quando quer garantir queries separadas
# - eager_load: Quando precisa WHERE na association
Post.includes(:author).where(users: { active: true })  # Precisa eager_load
```

### Counter Cache

```ruby
# 🚨 CRÍTICO: Count em loop
@users.each do |user|
  puts user.posts.count  # N queries
end

# ✅ SEGURO: Counter cache
# Migration:
add_column :users, :posts_count, :integer, default: 0, null: false

# Update existing:
User.find_each do |user|
  User.reset_counters(user.id, :posts)
end

# Model:
class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
end

# Uso:
@users.each do |user|
  puts user.posts_count  # Sem query!
end
```

## 2. Database Performance

### Índices

```ruby
# 🚨 CRÍTICO: Query sem índice
User.where(email: params[:email])  # Sem índice em email = table scan

# ✅ SEGURO: Adicionar índice
# Migration:
add_index :users, :email, unique: true
add_index :posts, :user_id  # Foreign keys SEMPRE precisam índice
add_index :posts, :published_at
add_index :posts, [:user_id, :published_at]  # Composite index

# Verificar queries lentas:
# Em development.rb:
config.after_initialize do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    if event.duration > 100  # Log queries > 100ms
      Rails.logger.warn "SLOW QUERY (#{event.duration.round(2)}ms): #{event.payload[:sql]}"
    end
  end
end
```

### Select Específico

```ruby
# 🚨 CRÍTICO: SELECT *
@users = User.all  # SELECT * FROM users (traz tudo)

# ✅ SEGURO: Selecionar apenas o necessário
@users = User.select(:id, :name, :email)
@users = User.select('id, name, email, created_at')

# Para JSON API:
render json: @users.select(:id, :name, :email)
```

### Batch Processing

```ruby
# 🚨 CRÍTICO: Carregar tudo em memória
User.all.each do |user|  # Carrega TODOS os users na RAM
  user.do_something
end

# ✅ SEGURO: Processar em batches
User.find_each(batch_size: 1000) do |user|
  user.do_something
end

# Ou in_batches para operações bulk:
User.in_batches(of: 1000) do |batch|
  batch.update_all(processed: true)
end

# Com limit:
User.where(active: true).find_each do |user|
  user.do_something
end
```

### Pluck vs Select

```ruby
# Para arrays simples, pluck é mais eficiente:
user_ids = User.where(active: true).pluck(:id)  # Array de IDs
emails = User.pluck(:email)  # Não instancia objetos AR

# Select + map ainda instancia objetos:
emails = User.select(:email).map(&:email)  # Mais lento
```

## 3. Background Jobs

### O que deve ser assíncrono

```ruby
# 🚨 CRÍTICO: Operações pesadas síncronas
def create
  @order = Order.create!(order_params)
  
  # Bloqueia request por segundos:
  send_confirmation_email(@order)  # 2s
  generate_invoice_pdf(@order)      # 5s
  sync_to_external_system(@order)   # 3s
  process_analytics(@order)         # 1s
  
  redirect_to @order  # Usuário espera 11 segundos!
end

# ✅ SEGURO: Background jobs
def create
  @order = Order.create!(order_params)
  
  # Enfileira para processar async:
  OrderConfirmationJob.perform_later(@order.id)
  InvoiceGenerationJob.perform_later(@order.id)
  ExternalSyncJob.perform_later(@order.id)
  AnalyticsJob.perform_later(@order.id)
  
  redirect_to @order  # Responde imediatamente
end

# Job:
class OrderConfirmationJob < ApplicationJob
  queue_as :default
  
  def perform(order_id)
    order = Order.find(order_id)
    OrderMailer.confirmation(order).deliver_now
  end
end
```

### Candidates para Background Jobs

- ✅ Envio de emails
- ✅ Chamadas a APIs externas (pagamento, shipping, etc)
- ✅ Processamento de arquivos (uploads, PDFs, imagens)
- ✅ Cálculos complexos e relatórios
- ✅ Limpeza de dados antigos
- ✅ Sincronização com sistemas externos
- ✅ Webhooks e notificações
- ✅ Anything que demora > 500ms

### Retry e Error Handling

```ruby
class ExternalApiJob < ApplicationJob
  queue_as :default
  retry_on ExternalApi::ServiceUnavailable, wait: 5.seconds, attempts: 3
  discard_on ExternalApi::InvalidRequest  # Não retry erros de validação
  
  def perform(user_id)
    user = User.find(user_id)
    ExternalApi.sync(user)
  rescue => e
    Rails.logger.error "ExternalApiJob failed: #{e.message}"
    ErrorTracker.notify(e, user_id: user_id)
    raise
  end
end
```

## 4. Caching

### Fragment Caching

```ruby
# View:
<% @posts.each do |post| %>
  <% cache post do %>
    <article>
      <h2><%= post.title %></h2>
      <p><%= post.body %></p>
    </article>
  <% end %>
<% end %>

# Invalida automaticamente quando post.updated_at muda
```

### Russian Doll Caching

```ruby
# Outer cache:
<% cache @post do %>
  <h1><%= @post.title %></h1>
  
  <% cache "comments-#{@post.id}" do %>
    <% @post.comments.each do |comment| %>
      <% cache comment do %>
        <p><%= comment.body %></p>
      <% end %>
    <% end %>
  <% end %>
<% end %>

# Atualizar comentário só invalida cache daquele comentário
# Para invalidar cache do post quando comentário muda:
class Comment < ApplicationRecord
  belongs_to :post, touch: true  # Atualiza post.updated_at
end
```

### Low-Level Caching

```ruby
# 🚨 CRÍTICO: Query pesada executada toda vez
def leaderboard
  User.joins(:scores)
      .group(:user_id)
      .select('users.*, SUM(scores.points) as total')
      .order('total DESC')
      .limit(100)
end

# ✅ SEGURO: Cache
def leaderboard
  Rails.cache.fetch('leaderboard', expires_in: 5.minutes) do
    User.joins(:scores)
        .group(:user_id)
        .select('users.*, SUM(scores.points) as total')
        .order('total DESC')
        .limit(100)
        .to_a  # Importante: converter para array
  end
end

# Cache com key dinâmica:
def user_stats(user_id)
  Rails.cache.fetch("user_stats/#{user_id}", expires_in: 1.hour) do
    calculate_stats(user_id)
  end
end
```

### Cache Invalidation

```ruby
# Invalidar manualmente:
Rails.cache.delete('leaderboard')
Rails.cache.delete_matched('user_stats/*')

# Em callbacks:
class Score < ApplicationRecord
  after_commit :clear_leaderboard_cache
  
  private
  
  def clear_leaderboard_cache
    Rails.cache.delete('leaderboard')
  end
end
```

## 5. Memory Management

### Streaming Large Files

```ruby
# 🚨 CRÍTICO: Carregar arquivo grande na RAM
def download
  file = File.read(large_file_path)  # Carrega tudo na memória
  send_data file
end

# ✅ SEGURO: Streaming
def download
  send_file large_file_path, stream: true, buffer_size: 4096
end

# Para S3/ActiveStorage:
def download
  redirect_to @document.file.url  # Let CDN handle it
end
```

### Lazy Loading

```ruby
# 🚨 CRÍTICO: Eager loading desnecessário
def show
  @user = User.includes(:posts, :comments, :followers, :following).find(params[:id])
  # Carrega tudo mas só usa user.name
end

# ✅ SEGURO: Carregar só o necessário
def show
  @user = User.find(params[:id])
  # Associations carregadas on-demand se necessário
end
```

### Avoid Large Collections in Memory

```ruby
# 🚨 CRÍTICO: Array gigante em memória
all_emails = User.pluck(:email)  # 1 milhão de emails na RAM
all_emails.each do |email|
  send_newsletter(email)
end

# ✅ SEGURO: Process em batches
User.select(:email).find_each do |user|
  send_newsletter(user.email)
end
```

## 6. HTTP & Network

### Timeouts

```ruby
# 🚨 CRÍTICO: Sem timeout
response = HTTParty.get(external_api_url)  # Pode travar forever

# ✅ SEGURO: Configurar timeouts
response = HTTParty.get(
  external_api_url,
  timeout: 5,  # 5 segundos
  open_timeout: 2
)

# Para Net::HTTP:
require 'net/http'
uri = URI(url)
http = Net::HTTP.new(uri.host, uri.port)
http.open_timeout = 2
http.read_timeout = 5
```

### Connection Pooling

```ruby
# Database connection pool:
# config/database.yml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  
# Para Redis:
redis_pool = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(url: ENV['REDIS_URL'])
end

redis_pool.with do |conn|
  conn.get('key')
end
```

## 7. Asset Optimization

### CDN

```ruby
# config/environments/production.rb
config.asset_host = ENV['CDN_URL']  # 'https://cdn.meuapp.com'
```

### Compression

```ruby
# Gzip/Brotli compression (geralmente configurado no nginx/proxy)
# Mas garantir assets precompilados:
rake assets:precompile
```

## Checklist de Escalabilidade

- [ ] **N+1 Queries**: Identificados e corrigidos com includes/preload?
- [ ] **Counter Cache**: Usado para counts frequentes?
- [ ] **Índices**: Foreign keys e WHERE clauses têm índices?
- [ ] **Select Específico**: Evitando SELECT * onde possível?
- [ ] **Batch Processing**: find_each para grandes volumes?
- [ ] **Background Jobs**: Operações pesadas são assíncronas?
- [ ] **Caching**: Queries/views pesadas têm cache?
- [ ] **Memory**: Não carrega coleções grandes em memória?
- [ ] **Timeouts**: APIs externas têm timeout configurado?
- [ ] **Connection Pool**: Pool size apropriado?

## Perguntas de Escalabilidade

1. "Este código funciona com 10x mais usuários?"
2. "Esta query é eficiente com 1 milhão de registros?"
3. "Esta operação deve ser síncrona ou assíncrona?"
4. "Há oportunidade de cache aqui?"
5. "Que índices este query precisa?"
