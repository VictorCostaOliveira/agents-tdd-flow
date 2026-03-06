# Exemplos Rails + Vue.js com TDD

Exemplos práticos de features Rails + Vue.js seguindo TDD e Better Specs.

## Better Specs - Referência Rápida

### 1. Use `expect` (nunca `should`)
```ruby
expect(user).to be_valid              # ✅
user.should be_valid                  # ❌
```

### 2. Organize com `describe` e `context`
```ruby
describe '#publish' do
  context 'when draft' do
    it 'changes status' do
      expect { post.publish }.to change(post, :status)
    end
  end
end
```

### 3. Descrições curtas (< 40 caracteres)
```ruby
it 'creates resource' do              # ✅
it 'should create a new resource...'  # ❌
```

### 4. Uma expectativa por teste (testes isolados)
```ruby
it { is_expected.to validate_presence_of(:email) }        # ✅ Isolado
it { is_expected.to validate_uniqueness_of(:email) }      # ✅ Isolado

it 'creates user with profile' do     # ✅ Integration OK
  expect(user).to be_valid
  expect(user.profile).to be_present
end
```

### 5. Use `let` e `let!`
```ruby
let(:user) { create(:user) }          # ✅ Lazy load
let!(:post) { create(:post) }         # ✅ Eager load
```

### 6. Use factories (não fixtures)
```ruby
let(:user) { create(:user) }          # ✅ FactoryBot
let(:user) { users(:john) }           # ❌ Fixtures
```

### 7. Frontend (mesmos princípios)
```javascript
describe('Component', () => {
  describe('when loaded', () => {
    it('renders content', () => {
      expect(wrapper.text()).toContain('Expected')
    })
  })
})
```

---

## Exemplo Completo: Feature de Comentários

### User Story
"Como usuário logado, quero comentar em posts para interagir com o conteúdo"

### Critérios de Aceite

**Cenário 1: Criar comentário com sucesso**
- DADO QUE sou um usuário autenticado e estou visualizando um post
- QUANDO submeto um comentário válido
- ENTÃO o comentário é criado e exibido na lista

**Cenário 2: Validação de comentário vazio**
- DADO QUE sou um usuário autenticado
- QUANDO tento submeter um comentário vazio
- ENTÃO recebo mensagem de erro de validação

**Cenário 3: Usuário não autenticado**
- DADO QUE não estou autenticado
- QUANDO tento criar um comentário
- ENTÃO recebo erro 401 Unauthorized

---

## 🧪 FASE 1: Testes Backend (RED)

### Model Spec
```ruby
# spec/models/comment_spec.rb
RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:author).class_name('User') }
  end
  
  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(500) }
  end
  
  describe '#created_today?' do
    context 'when created today' do
      let(:comment) { create(:comment, created_at: Time.current) }
      it { expect(comment.created_today?).to be true }
    end
    
    context 'when created yesterday' do
      let(:comment) { create(:comment, created_at: 1.day.ago) }
      it { expect(comment.created_today?).to be false }
    end
  end
end
```

### Request Spec
```ruby
# spec/requests/api/v1/comments_spec.rb
RSpec.describe 'Comments API', type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }
  let(:headers) { { 'Authorization' => "Bearer #{user.token}" } }
  let(:url) { "/api/v1/posts/#{post_record.id}/comments" }
  
  describe 'GET /api/v1/posts/:post_id/comments' do
    context 'when comments exist' do
      let!(:comments) { create_list(:comment, 3, post: post_record) }
      
      before { get url, headers: headers }
      
      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns all comments' do
        expect(JSON.parse(response.body).size).to eq(3)
      end
      
      it 'includes author data' do
        json = JSON.parse(response.body)
        expect(json.first).to have_key('author')
      end
    end
  end
  
  describe 'POST /api/v1/posts/:post_id/comments' do
    context 'with valid params' do
      let(:valid_params) { { comment: { content: 'Great post!' } } }
      
      it 'creates comment' do
        expect {
          post url, params: valid_params, headers: headers
        }.to change(Comment, :count).by(1)
      end
      
      it 'returns created status' do
        post url, params: valid_params, headers: headers
        expect(response).to have_http_status(:created)
      end
      
      it 'associates with current user' do
        post url, params: valid_params, headers: headers
        expect(Comment.last.author).to eq(user)
      end
    end
    
    context 'with invalid params' do
      let(:invalid_params) { { comment: { content: '' } } }
      
      it 'does not create comment' do
        expect {
          post url, params: invalid_params, headers: headers
        }.not_to change(Comment, :count)
      end
      
      it 'returns unprocessable entity' do
        post url, params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    
    context 'when not authenticated' do
      it 'returns unauthorized' do
        post url, params: { comment: { content: 'Test' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
    
    context 'when post not found' do
      it 'returns not found' do
        post "/api/v1/posts/99999/comments",
             params: { comment: { content: 'Test' } },
             headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
```

---

## 🏗️ FASE 2: Implementação Backend (GREEN)

### Migration
```ruby
# db/migrate/20260210_create_comments.rb
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.text :content, null: false
      t.timestamps
    end
    
    add_index :comments, :created_at
    add_index :comments, [:post_id, :created_at]
  end
end
```

### Model
```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: 'User'
  
  validates :content, presence: true, length: { maximum: 500 }
  
  scope :recent, -> { order(created_at: :desc) }
  
  def created_today?
    created_at.to_date == Date.current
  end
end

# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
end

# app/models/user.rb
class User < ApplicationRecord
  has_many :comments, foreign_key: :author_id, dependent: :destroy
end
```

### Controller
```ruby
# app/controllers/api/v1/comments_controller.rb
class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  
  def index
    @comments = @post.comments.includes(:author).recent
    render json: @comments, include: :author
  end
  
  def create
    @comment = @post.comments.build(comment_params)
    @comment.author = current_user
    
    if @comment.save
      render json: @comment, include: :author, status: :created
    else
      render json: { errors: @comment.errors }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_post
    @post = Post.find(params[:post_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Post not found' }, status: :not_found
  end
  
  def comment_params
    params.require(:comment).permit(:content)
  end
end
```

### Routes
```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :posts do
      resources :comments, only: [:index, :create]
    end
  end
end
```

### Factory
```ruby
# spec/factories/comments.rb
FactoryBot.define do
  factory :comment do
    association :post
    association :author, factory: :user
    content { Faker::Lorem.paragraph }
  end
end
```

---

## 🧪 FASE 3: Testes Frontend (RED)

### Store Spec
```javascript
// stores/comments.spec.js
import { setActivePinia, createPinia } from 'pinia'
import { useCommentsStore } from './comments'

describe('Comments Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    global.fetch = vi.fn()
  })
  
  describe('fetchComments', () => {
    it('loads comments for post', async () => {
      const mockComments = [{ id: 1, content: 'Test' }]
      global.fetch.mockResolvedValueOnce({
        json: async () => mockComments
      })
      
      const store = useCommentsStore()
      await store.fetchComments(1)
      
      expect(store.comments).toEqual(mockComments)
    })
    
    it('handles errors', async () => {
      global.fetch.mockRejectedValueOnce(new Error('Network error'))
      
      const store = useCommentsStore()
      await store.fetchComments(1)
      
      expect(store.error).toBe('Network error')
    })
  })
  
  describe('addComment', () => {
    it('adds comment to store', async () => {
      const newComment = { id: 1, content: 'New' }
      global.fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => newComment
      })
      
      const store = useCommentsStore()
      await store.addComment(1, 'New')
      
      expect(store.comments).toHaveLength(1)
      expect(store.comments[0]).toEqual(newComment)
    })
    
    it('throws error on failure', async () => {
      global.fetch.mockResolvedValueOnce({ ok: false })
      
      const store = useCommentsStore()
      await expect(store.addComment(1, 'Test')).rejects.toThrow()
    })
  })
})
```

### Component Specs
```javascript
// components/CommentForm.spec.js
import { mount } from '@vue/test-utils'
import CommentForm from './CommentForm.vue'

describe('CommentForm', () => {
  describe('when submitting', () => {
    it('emits submit event with content', async () => {
      const wrapper = mount(CommentForm)
      await wrapper.find('textarea').setValue('Great post!')
      await wrapper.find('form').trigger('submit')
      
      expect(wrapper.emitted('submit')).toBeTruthy()
      expect(wrapper.emitted('submit')[0][0]).toBe('Great post!')
    })
    
    it('clears textarea after submit', async () => {
      const wrapper = mount(CommentForm)
      const textarea = wrapper.find('textarea')
      await textarea.setValue('Test')
      await wrapper.find('form').trigger('submit')
      
      expect(textarea.element.value).toBe('')
    })
  })
  
  describe('when content is empty', () => {
    it('does not emit submit', async () => {
      const wrapper = mount(CommentForm)
      await wrapper.find('form').trigger('submit')
      
      expect(wrapper.emitted('submit')).toBeFalsy()
    })
  })
})

// components/CommentList.spec.js
import { mount } from '@vue/test-utils'
import CommentList from './CommentList.vue'

describe('CommentList', () => {
  const comments = [
    { id: 1, content: 'First', author: { name: 'John' }, created_at: '2026-02-10' },
    { id: 2, content: 'Second', author: { name: 'Jane' }, created_at: '2026-02-10' }
  ]
  
  describe('when comments exist', () => {
    it('renders all comments', () => {
      const wrapper = mount(CommentList, { props: { comments } })
      expect(wrapper.findAll('.comment')).toHaveLength(2)
    })
    
    it('displays content and authors', () => {
      const wrapper = mount(CommentList, { props: { comments } })
      expect(wrapper.text()).toContain('First')
      expect(wrapper.text()).toContain('John')
    })
  })
  
  describe('when comments are empty', () => {
    it('shows empty message', () => {
      const wrapper = mount(CommentList, { props: { comments: [] } })
      expect(wrapper.text()).toContain('No comments yet')
    })
  })
})
```

---

## 🏗️ FASE 4: Implementação Frontend (GREEN)

### Store Pinia
```javascript
// stores/comments.js
import { defineStore } from 'pinia'

export const useCommentsStore = defineStore('comments', {
  state: () => ({
    comments: [],
    loading: false,
    error: null
  }),
  
  getters: {
    commentCount: (state) => state.comments.length,
    hasComments: (state) => state.comments.length > 0
  },
  
  actions: {
    async fetchComments(postId) {
      this.loading = true
      this.error = null
      
      try {
        const response = await fetch(`/api/v1/posts/${postId}/comments`)
        this.comments = await response.json()
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },
    
    async addComment(postId, content) {
      this.loading = true
      this.error = null
      
      try {
        const response = await fetch(`/api/v1/posts/${postId}/comments`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('token')}`
          },
          body: JSON.stringify({ comment: { content } })
        })
        
        if (!response.ok) throw new Error('Failed to create comment')
        
        const comment = await response.json()
        this.comments.unshift(comment)
      } catch (error) {
        this.error = error.message
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})
```

### Componente Form
```vue
<!-- components/CommentForm.vue -->
<script setup>
import { ref } from 'vue'

const content = ref('')
const emit = defineEmits(['submit'])

function handleSubmit() {
  if (content.value.trim()) {
    emit('submit', content.value)
    content.value = ''
  }
}
</script>

<template>
  <form @submit.prevent="handleSubmit" class="comment-form">
    <textarea
      v-model="content"
      placeholder="Write a comment..."
      maxlength="500"
      rows="3"
      class="comment-form__textarea"
    />
    <button type="submit" class="comment-form__button">
      Post Comment
    </button>
  </form>
</template>

<style scoped lang="scss">
.comment-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  
  &__textarea {
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    resize: vertical;
    
    &:focus {
      outline: none;
      border-color: #007bff;
    }
  }
  
  &__button {
    align-self: flex-end;
    padding: 0.5rem 1rem;
    background: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    
    &:hover {
      background: #0056b3;
    }
  }
}
</style>
```

### Componente List
```vue
<!-- components/CommentList.vue -->
<script setup>
defineProps({
  comments: {
    type: Array,
    required: true
  }
})
</script>

<template>
  <div class="comment-list">
    <div v-if="comments.length === 0" class="comment-list__empty">
      No comments yet. Be the first to comment!
    </div>
    
    <div
      v-for="comment in comments"
      :key="comment.id"
      class="comment"
    >
      <div class="comment__header">
        <strong class="comment__author">{{ comment.author.name }}</strong>
        <span class="comment__date">{{ comment.created_at }}</span>
      </div>
      <p class="comment__content">{{ comment.content }}</p>
    </div>
  </div>
</template>

<style scoped lang="scss">
.comment-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  
  &__empty {
    padding: 2rem;
    text-align: center;
    color: #666;
  }
}

.comment {
  padding: 1rem;
  border: 1px solid #eee;
  border-radius: 4px;
  
  &__header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.5rem;
  }
  
  &__author {
    font-size: 0.875rem;
  }
  
  &__date {
    color: #999;
    font-size: 0.75rem;
  }
  
  &__content {
    margin: 0;
    color: #555;
    line-height: 1.5;
  }
}
</style>
```

### Página de Integração
```vue
<!-- pages/PostDetail.vue -->
<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useCommentsStore } from '@/stores/comments'
import CommentForm from '@/components/CommentForm.vue'
import CommentList from '@/components/CommentList.vue'

const route = useRoute()
const commentsStore = useCommentsStore()
const postId = ref(route.params.id)

onMounted(() => {
  commentsStore.fetchComments(postId.value)
})

async function handleCommentSubmit(content) {
  try {
    await commentsStore.addComment(postId.value, content)
  } catch (error) {
    alert('Failed to post comment')
  }
}
</script>

<template>
  <div class="post-detail">
    <section class="comments-section">
      <h2>Comments</h2>
      <CommentForm @submit="handleCommentSubmit" />
      
      <div v-if="commentsStore.loading">Loading...</div>
      <div v-if="commentsStore.error" class="error">{{ commentsStore.error }}</div>
      
      <CommentList :comments="commentsStore.comments" />
    </section>
  </div>
</template>

<style scoped lang="scss">
.comments-section {
  margin-top: 2rem;
  
  h2 {
    margin-bottom: 1.5rem;
  }
}

.error {
  padding: 1rem;
  background: #fee;
  color: #c33;
  border-radius: 4px;
  margin: 1rem 0;
}
</style>
```

---

## Padrões Adicionais

### Service Object (lógica complexa)
```ruby
# app/services/comments/create_service.rb
module Comments
  class CreateService
    def initialize(post:, author:, content:)
      @post = post
      @author = author
      @content = content
    end
    
    def call
      comment = @post.comments.build(content: @content, author: @author)
      
      if comment.save
        notify_post_author
        Result.success(comment)
      else
        Result.failure(comment.errors)
      end
    end
    
    private
    
    def notify_post_author
      CommentNotificationJob.perform_later(@post.author_id)
    end
  end
end

# Uso no controller:
def create
  result = Comments::CreateService.new(
    post: @post,
    author: current_user,
    content: comment_params[:content]
  ).call
  
  if result.success?
    render json: result.value, status: :created
  else
    render json: { errors: result.error }, status: :unprocessable_entity
  end
end
```

### Composable (API calls)
```javascript
// composables/useCommentApi.js
import { ref } from 'vue'

export function useCommentApi() {
  const loading = ref(false)
  const error = ref(null)
  
  async function createComment(postId, content) {
    loading.value = true
    error.value = null
    
    try {
      const response = await fetch(`/api/v1/posts/${postId}/comments`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({ comment: { content } })
      })
      
      if (!response.ok) throw new Error('Failed')
      return await response.json()
    } catch (e) {
      error.value = e.message
      throw e
    } finally {
      loading.value = false
    }
  }
  
  return { loading, error, createComment }
}
```

---

## 🔄 Ordem de Execução TDD

### Fase 1: Backend (RED → GREEN)
1. Escrever model specs → Criar migration e model → `rspec spec/models/comment_spec.rb` ✅
2. Escrever request specs → Criar controller e routes → `rspec spec/requests` ✅

### Fase 2: Frontend (RED → GREEN)
3. Escrever store specs → Criar store Pinia → `npm run test stores` ✅
4. Escrever component specs → Criar componentes → `npm run test components` ✅

### Fase 3: Integração & Refactor
5. Integrar componentes com store
6. Teste manual (smoke test)
7. Refatorar código
8. Code review

---

## ⚠️ Considerações

### Segurança
- ✅ Autenticação JWT
- ✅ Strong parameters (mass assignment)
- ✅ Ownership validation
- ✅ XSS prevention (Vue escapa por padrão)
- ✅ CSRF protection (Rails)
- ✅ Rate limiting

### Performance
- ✅ Eager loading: `includes(:author)`
- ✅ Índices: `[:post_id, :created_at]`
- ✅ Scope para queries comuns
- ⚠️ Adicionar paginação se > 100 comentários
- ⚠️ Cache de contagem (counter_cache)

### Edge Cases
- ✅ Post não encontrado → 404
- ✅ Comentário vazio → validação
- ✅ Comentário muito longo → validação 500 chars
- ✅ Usuário não autenticado → 401
- ⚠️ Concorrência (múltiplos comentários simultâneos)
- ⚠️ Post deletado (usar soft delete)

---

## Checklist de Implementação

### Backend
- [ ] Escrever model specs
- [ ] Criar migration com índices
- [ ] Implementar model
- [ ] Escrever request specs
- [ ] Implementar controller (skinny)
- [ ] Adicionar routes
- [ ] Criar factory
- [ ] `bundle exec rspec` → todos passam

### Frontend
- [ ] Escrever store specs
- [ ] Implementar store Pinia
- [ ] Escrever component specs
- [ ] Implementar componentes
- [ ] Adicionar styles
- [ ] `npm run test` → todos passam

### Validação
- [ ] Better Specs seguido?
- [ ] N+1 queries prevenidas?
- [ ] Segurança implementada?
- [ ] Edge cases cobertos?
