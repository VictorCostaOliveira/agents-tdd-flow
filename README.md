# Rails + Vue.js Development Agents

Uma suite de agentes especializados para desenvolvimento Rails + Vue.js seguindo TDD e boas práticas.

## 🎯 Agentes Disponíveis

### Fluxo principal (Rails + Vue.js)

#### 1. requison (Analista de Requisitos) ⭐
**Analista de Requisitos Sênior**

Levanta requisitos funcionais e não-funcionais através de perguntas estratégicas. Use ANTES de planejar ou implementar quando a demanda estiver vaga.

- **Perguntas Estratégicas**: Descobre requisitos através de questionamento estruturado
- **Requisitos Completos**: Funcionais, não funcionais, edge cases, dependências
- **Documentação**: Critérios de aceite Given-When-Then
- **Uso**: Use proativamente ANTES de planejar ou implementar features ⚠️

#### 2. ana (Planejadora TDD)
**Arquiteta Rails + Vue.js (TDD-First)**

Transforma requisitos em planos executáveis com **testes primeiro** (Better Specs).

- **Rails**: REST APIs, Active Record, RSpec, Service Objects
- **Vue.js 3**: Composition API, Pinia, Vitest
- **TDD**: Red-Green-Refactor, specs RSpec/Vitest antes da implementação
- **Uso**: Após requison levantar requisitos

#### 3. devoso (Desenvolvedor Sênior)
**Implementação Vue + Rails**

Implementa código seguindo plano e testes; respeita testes existentes e roda testes a cada alteração.

- **Apenas código**: Não altera specs/requisitos a menos que pedido
- **Nunca altera testes**: Código obedece ao contrato dos testes
- **Testes a cada mudança**: Roda testes do contexto afetado antes de seguir
- **Knowledge**: Consulta `knowledge/` para boas práticas
- **Uso**: Implementações em Vue (Composition API, Pinia) e Rails (models, controllers, services)

#### 4. verifier (Validador Independente) ⭐
**Validador Cético**

Confirma se o trabalho declarado como completo realmente funciona.

- **Processo**: Executa testes, edge cases, fluxo de ponta a ponta
- **Uso**: Proativo APÓS devoso marcar implementação concluída
- **Benefício**: Identifica implementações incompletas antes de considerar feature pronta

#### 5. avaliason (Revisor de Código)
**Code Review Expert**

Revisão estruturada das mudanças atuais (git) com foco em SOLID, segurança, performance e tratamento de erros.

- **Severidade**: P0 (crítico) a P3 (baixo); review-only por padrão
- **Foco**: SOLID, segurança, race conditions, performance, boundary conditions
- **Uso**: Proativo após modificações; NÃO implementa sem confirmação explícita

### Especialistas

#### testivos (Testes)
Expert em testes: frontend (Vue 3 + Vitest/Jest) e backend (RSpec em Rails). Use para escrever, revisar ou corrigir testes e para melhorar cobertura.

#### infrason (Infraestrutura e DevOps)
Especialista em Docker, Kubernetes, CI/CD, monitoramento e deploy. Use para criar, configurar ou otimizar infraestrutura e pipelines.

#### cobrinha (Python)
Especialista em projetos Python: arquiteturas, estruturação, ambientes, dependências, Dockerfiles e boas práticas.

#### robs (Padrões Frontend)
Mapeia e documenta padrões, convenções e decisões de arquitetura no frontend. Ideal para onboarding e documentação viva.

#### wiki (Pesquisa Técnica)
Pesquisa e explica conceitos técnicos, tecnologias e ferramentas; analisa tradeoffs e apresenta visões completas.

## 🚀 Como Usar

### Workflow Completo: Feature do Zero à Implementação

#### Workflow Recomendado ⭐

1. **Análise de Requisitos** → Use `requison` para levantar requisitos completos
2. **Planejamento TDD** → Use `ana` para criar plano e testes
3. **Implementação** → Use `devoso` para desenvolver código
4. **Validação** → Use `verifier` para confirmar que realmente funciona
5. **Revisão** → Use `avaliason` para revisar qualidade (SOLID, segurança, performance)

#### Por que começar com Requison?

Começar com análise de requisitos garante:
- ✅ Nenhuma ambiguidade ou gap nos requisitos
- ✅ Todos os edge cases identificados
- ✅ Requisitos não funcionais mapeados (segurança, performance)
- ✅ Ana tem especificação completa para trabalhar
- ✅ Menos retrabalho e surpresas durante implementação

### Exemplos de Uso por Agente

#### requison: Análise de Requisitos ⭐

```
Preciso implementar um sistema de comentários nos posts.
Use o requison para levantar todos os requisitos funcionais e não funcionais.
```

**Output**: Documentação completa com requisitos funcionais, não funcionais, casos de uso, edge cases, critérios de aceite e dependências.

#### ana: Criar Plano TDD

```
Já tenho os requisitos completos do sistema de comentários levantados pelo requison.
Use a ana para criar um plano TDD completo com testes.
```

**Output**: Plano com testes RSpec + Vitest especificados primeiro, depois design de implementação.

#### devoso: Implementar Feature

```
Tenho o plano de comentários pronto e os testes escritos pela ana.
Use o devoso para implementar o código até todos os testes passarem.
```

**Output**: Implementação completa (backend + frontend) com todos os testes passando.

#### verifier: Validar Implementação ⭐

```
Use o verifier para confirmar que o sistema de comentários realmente funciona.
```

**Output**: Validação independente confirmando o que funciona vs o que está incompleto.

#### avaliason: Revisar Código

```
Use o avaliason para analisar o código de comentários implementado e validado.
```

**Output**: Revisão estruturada (severidade P0–P3) em SOLID, segurança, performance e sugestões de melhoria.

### Exemplos Combinados

#### Feature Completa (Análise + Planejamento + Implementação + Validação + Revisão)
```
User Story: Sistema de likes nos posts

1. requison: Levanta requisitos funcionais e não funcionais
2. ana: Cria plano TDD com testes especificados
3. devoso: Implementa código até todos os testes passarem
4. verifier: Valida que realmente funciona de ponta a ponta
5. avaliason: Revisa código para garantir qualidade
```

#### API + Frontend do Zero
```
Preciso criar endpoints REST para gerenciar produtos e a interface Vue.

requison: Levanta todos os requisitos (auth, validações, edge cases, performance)
ana: Desenha a solução completa com testes primeiro
devoso: Implementa backend Rails + frontend Vue seguindo padrões do projeto
verifier: Confirma que tudo funciona de ponta a ponta (testes + fluxo real)
avaliason: Valida segurança, SOLID, performance e consistência
```

## 🤔 Quando Usar Cada Agente

### Use o Requison (Analista de Requisitos) quando:

✅ Você recebe uma **demanda nova** de feature
✅ Requisitos estão **vagos ou incompletos**
✅ Precisa mapear **edge cases e validações**
✅ Precisa definir **requisitos não funcionais** (segurança, performance)
✅ Quer garantir **nenhuma ambiguidade** antes de implementar

**Exemplo**: "Implementar sistema de notificações" (muito vago!)

### Use a Ana (Planejadora) quando:

✅ Requisitos já estão **claros e completos**
✅ Precisa criar **plano TDD** com testes especificados
✅ Quer **design de implementação** detalhado
✅ Requisitos funcionais e não funcionais já estão mapeados

**Exemplo**: "Já tenho requisitos completos, preciso do plano técnico"

### Use o Devoso (Desenvolvedor) quando:

✅ Já tem **plano e testes prontos**
✅ Só precisa de **implementação pura**
✅ Testes já estão escritos e validados
✅ Sabe exatamente o que implementar

**Exemplo**: "Tenho os testes, só implementar"

### Use o Verifier (Validador) quando:

✅ Devoso **marcou tasks como concluídas**
✅ Quer **confirmar que realmente funciona**
✅ Precisa **validar de ponta a ponta**
✅ Quer **identificar implementações incompletas**

**Exemplo**: "Verificar se sistema de comentários está realmente completo"

### Use o Avaliason (Revisor) quando:

✅ Código já foi **implementado e validado**
✅ Precisa validar **segurança, SOLID, performance**
✅ Quer **revisão estruturada** das mudanças (git) com níveis de severidade
✅ Precisa de **sugestões de melhoria** (review-only por padrão)

**Exemplo**: "Revisar PR de comentários"

## 📋 O Que Cada Agente Entrega

### requison (Analista de Requisitos) ⭐

**Output**: Documentação completa de requisitos incluindo:

1. **Contexto do Projeto** - Arquitetura, padrões, integrações, restrições
2. **Requisitos Funcionais** - Fluxos, validações, casos de erro, edge cases
3. **Requisitos Não Funcionais** - Segurança, performance, escalabilidade, observabilidade
4. **Casos de Uso** - Fluxos principais, alternativos e de exceção
5. **Critérios de Aceite** - Given-When-Then para cada cenário
6. **Dependências e Riscos** - Impactos, integrações, pontos de atenção
7. **Estimativa de Complexidade** - Tamanho da feature e justificativa

### ana (Planejadora)

**Output**: Plano TDD completo incluindo:

1. **Critérios de Aceite** - Cenários Given-When-Then, edge cases
2. **Especificação de Testes (RED)** - RSpec + Vitest escritos ANTES da implementação
3. **Design de Implementação (GREEN)** - Backend Rails + Frontend Vue
4. **Plano de Execução** - Fases TDD com ordem de implementação
5. **Considerações Técnicas** - Segurança, performance, rollback

### devoso (Desenvolvedor)

**Output**: Código implementado incluindo:

1. **Backend Rails** - Migrations, Models, Controllers, Routes
2. **Frontend Vue** - Stores Pinia, Composables, Components
3. **Todos os Testes Passando** - `rspec` ✅ + `npm run test` ✅
4. **Código Limpo** - SOLID, DRY, métodos < 15 linhas
5. **Sem Alterações nos Testes** - Testes originais intactos


### verifier (Validador) ⭐

**Output**: Validação independente incluindo:

1. **Resultados dos Testes** - Backend (RSpec) e Frontend (Vitest) com status
2. **O Que Funciona** - Features realmente implementadas e operacionais
3. **O Que Está Incompleto** - Problemas específicos encontrados com reprodução
4. **Edge Cases Não Tratados** - Cenários que precisam atenção
5. **Resumo de Completude** - Taxa real de conclusão e próximas ações

### avaliason (Revisor)

**Output**: Revisão estruturada incluindo:

1. **Problemas de Segurança** - Auth, validations, SQL injection, XSS
2. **Violações SOLID** - SRP, OCP, LSP, ISP, DIP
3. **Problemas de Performance** - N+1 queries, eager loading
4. **Code Smells** - Duplicação, complexidade, acoplamento
5. **Sugestões de Melhoria** - Refactorings específicos

## 🗂️ Estrutura do Projeto

```
.cursor/agents/
├── requison.md                     # 🎯 Analista de requisitos (levanta RF e RNF) ⭐
├── ana.md                          # 📐 Arquiteta & Planejadora TDD (testes primeiro)
├── devoso.md                       # 🛠️ Desenvolvedor sênior Vue + Rails (implementação)
├── verifier.md                     # ✅ Validador cético (confirma que funciona) ⭐
├── avaliason.md                    # 🔍 Revisor de código (SOLID, segurança, performance)
├── testivos.md                     # 🧪 Especialista em testes (Vitest, RSpec)
├── infrason.md                     # 🐳 Infraestrutura e DevOps (Docker, K8s, CI/CD)
├── cobrinha.md                     # 🐍 Especialista Python
├── robs.md                         # 📐 Padrões e documentação frontend
├── wiki.md                         # 📚 Pesquisa e conceitos técnicos
├── knowledge/                      # 📚 Base de conhecimento compartilhada
│   ├── architecture.md             # SOLID e design patterns
│   ├── backend.md                  # Padrões de arquitetura backend
│   ├── frontend.md                 # Vue.js + Pinia best practices
│   ├── rails-code-quality.md       # Qualidade de código Rails
│   ├── rails-scalability.md        # Escalabilidade Rails
│   ├── rails-security.md           # Segurança Rails
│   ├── rails-solid.md              # SOLID aplicado ao Rails
│   ├── rails-vue-examples.md       # Exemplos práticos Rails + Vue
│   └── templates.md                # Templates de planejamento
└── README.md                       # 📖 Esta documentação
```

## 📚 Base de Conhecimento

O agente consulta automaticamente a base de conhecimento durante o planejamento:

### Rails Backend
- `knowledge/rails-solid.md` - SOLID principles aplicados ao Rails
- `knowledge/rails-security.md` - Segurança Rails (auth, validations)
- `knowledge/rails-scalability.md` - N+1 queries, eager loading, caching
- `knowledge/rails-code-quality.md` - Best practices Rails

### Vue.js Frontend
- `knowledge/frontend.md` - Vue.js 3, Pinia, componentização, reatividade
- Composition API, composables, scoped styles
- Testes com Vitest seguindo Better Specs

### Arquitetura e Padrões
- `knowledge/architecture.md` - SOLID, Design Patterns, DDD
- `knowledge/backend.md` - API design, camadas, serviços
- `knowledge/templates.md` - Templates de planejamento

### Better Specs
- Referência: https://www.betterspecs.org/
- Use `expect` syntax (nunca `should`)
- Organize com `describe` e `context`
- Uma expectativa por teste (quando possível)
- Use `let` e `let!` para setup
- Factories (FactoryBot), não fixtures

## 🎓 Princípios Seguidos

Todos os agentes seguem:

1. **Requisitos Primeiro** ⭐: Requison levanta requisitos completos ANTES de qualquer planejamento ou código
2. **Padrões Existentes Primeiro** ⚠️: Em projetos existentes, SEMPRE analisar e seguir os padrões já implementados
3. **Test-First**: Ana define testes ANTES da implementação (TDD)
4. **Red-Green-Refactor**: RED (testes falham) → GREEN (implementa) → REFACTOR (limpa)
5. **Validação Independente** ⭐: Verifier confirma que "completo" realmente funciona
6. **Better Specs**: https://www.betterspecs.org/ em RSpec E Vitest
7. **SOLID Principles**: Código limpo, coeso, manutenível
8. **Security by Default**: Auth, validations, proteções desde o início
9. **Performance Optimization**: N+1 prevention, eager loading, indexação
10. **Never Touch Tests**: Devoso NUNCA altera testes, apenas implementa código
11. **Consistency > Perfection**: Manter consistência com código existente é mais importante que "fazer do jeito perfeito"

## ⚙️ Workflow TDD Completo

### Fase 1: Planejamento (ana)

```
INPUT: User story / Card Jira
↓
1. Análise de requisitos
2. Critérios de aceite (Given-When-Then)
3. Especificação de testes (RED PHASE)
   - RSpec (backend)
   - Vitest (frontend)
4. Design de implementação (GREEN PHASE)
5. Plano de execução em fases
↓
OUTPUT: Plano TDD completo + Testes escritos
```

### Fase 2: Implementação (devoso)

```
INPUT: Plano + Testes escritos
↓
1. Executar testes → Todos falham (RED) ✅
2. Backend Rails
   - Migration → Model → Controller → Routes
   - Rodar testes após cada camada
3. Frontend Vue
   - Store → Composables → Components
   - Rodar testes após cada camada
4. Executar TODOS os testes → Todos passam (GREEN) ✅
5. Refactor (se necessário)
↓
OUTPUT: Feature completa funcionando
```

### Fase 3: Validação (verifier) ⭐

```
INPUT: Código implementado
↓
1. Executar testes (rspec + npm test)
2. Verificar implementação real
3. Testar edge cases
4. Validar fluxo de ponta a ponta
5. Identificar problemas
↓
OUTPUT: Relatório de validação (o que funciona vs incompleto)
```

### Fase 4: Revisão (avaliason)

```
INPUT: Código implementado
↓
1. Análise de segurança
2. Análise SOLID
3. Análise de performance
4. Code smells
5. Sugestões de melhoria
↓
OUTPUT: Relatório de qualidade + Refactorings
```

## 🔄 Ciclo Completo: Exemplo Prático

### User Story: Sistema de Comentários em Posts

**Workflow Completo** (5 fases) ⭐

**1. ANÁLISE DE REQUISITOS** → `requison`
```
Input: "Preciso implementar sistema de comentários nos posts"

Requison faz perguntas:
  - Quem pode comentar? Apenas logados?
  - Pode editar/deletar comentários?
  - Há limite de caracteres?
  - Precisa moderar comentários?
  - Notifica autor do post?
  - Como lidar com spam?
  - Soft delete ou hard delete?
  - Etc...

Output:
  ✓ Requisitos funcionais completos
  ✓ Requisitos não funcionais (segurança, performance)
  ✓ Casos de uso mapeados
  ✓ Edge cases identificados
  ✓ Critérios de aceite definidos
  ✓ Dependências e riscos conhecidos
```

**2. PLANEJAMENTO TDD** → `ana`
```
Input: Requisitos completos do requison

Output:
  ✓ Testes RSpec escritos (Comment model + API)
  ✓ Testes Vitest escritos (CommentStore + Components)
  ✓ Design: Migration, Model, Controller, Routes, Store, Components
  ✓ Plano de execução em fases
```

**3. IMPLEMENTAR** → `devoso`
```
Input: Plano da ana + Testes escritos

Workflow:
  0. Analisa padrões do projeto existente
  1. Roda testes → RED (todos falham)
  2. Cria migration CreateComments (seguindo padrões)
  3. Implementa Comment model
  4. Roda model specs → GREEN ✅
  5. Implementa CommentsController
  6. Roda request specs → GREEN ✅
  7. Implementa useCommentsStore
  8. Roda store specs → GREEN ✅
  9. Implementa CommentForm, CommentList
  10. Roda component specs → GREEN ✅
  11. Roda TODOS testes → GREEN ✅

Output: Feature implementada com testes passando
```

**4. VALIDAR** → `verifier` ⭐
```
Input: Código implementado pelo devoso

Workflow:
  1. Executa todos os testes (rspec + npm test)
  2. Verifica implementação real (não só testes)
  3. Testa edge cases (validações, erros, concorrência)
  4. Valida fluxo de ponta a ponta
  5. Identifica implementações incompletas

Output:
  ✓ O que realmente funciona
  ✓ O que está incompleto (se houver)
  ✓ Edge cases não tratados
  ✓ Taxa real de completude
```

**5. REVISAR** → `avaliason`
```
Input: Código implementado pelo devoso

Output:
  ✓ Segurança OK (auth, validations)
  ✓ SOLID OK (SRP, DRY)
  ✓ Consistência OK (seguiu padrões do projeto)
  ✓ Performance: Sugestão de adicionar eager loading
  ✓ Sugestão: Extrair CommentCreator service (opcional)
```

**RESULTADO FINAL**: Feature completa, testada, **validada**, revisada e documentada! 🎉

## 📖 Exemplo de Saída por Agente

### 📐 ana (Planejadora) Output

**🧪 Testes Backend (escritos pelo planner)**
```ruby
# spec/models/comment_spec.rb
RSpec.describe Comment, type: :model do
  it { is_expected.to belong_to(:post) }
  it { is_expected.to belong_to(:author).class_name('User') }
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_length_of(:content).is_at_most(500) }
end

# spec/requests/api/v1/comments_spec.rb
RSpec.describe 'Comments API', type: :request do
  describe 'POST /api/v1/posts/:post_id/comments' do
    it 'creates comment' do
      expect { post url, params: valid_params, headers: auth_headers }
        .to change(Comment, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end
end
```

**🧪 Testes Frontend (escritos pelo planner)**
```javascript
// stores/comments.spec.js
describe('useCommentsStore', () => {
  it('creates comment', async () => {
    const store = useCommentsStore()
    await store.createComment(postId, content)
    expect(store.comments).toHaveLength(1)
  })
})

// components/CommentForm.spec.js
describe('CommentForm', () => {
  it('emits submit with content', async () => {
    const wrapper = mount(CommentForm)
    await wrapper.find('textarea').setValue('Nice post!')
    await wrapper.find('form').trigger('submit')
    expect(wrapper.emitted('submit')[0][0]).toBe('Nice post!')
  })
})
```

**🏗️ Plano de Implementação (guia para developer)**
```
Backend:
  1. Migration: create_table :comments (post_id, author_id, content)
  2. Model: validations, associations, methods
  3. Controller: create, update, destroy actions
  4. Routes: resources :comments, only: [:create, :update, :destroy]

Frontend:
  1. Store: useCommentsStore (state, getters, actions)
  2. Composables: useCommentForm (validations)
  3. Components: CommentForm.vue, CommentList.vue, CommentItem.vue
```

### 🛠️ devoso (Desenvolvedor) Output

**Implementação Real (código que faz testes passarem)**

```ruby
# app/models/comment.rb (implementado pelo developer)
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: 'User'
  
  validates :content, presence: true, length: { maximum: 500 }
end

# app/controllers/api/v1/comments_controller.rb
class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @comment = current_user.comments.build(comment_params)
    
    if @comment.save
      render json: @comment, status: :created
    else
      render json: { errors: @comment.errors }, status: :unprocessable_entity
    end
  end
  
  private
  
  def comment_params
    params.require(:comment).permit(:post_id, :content)
  end
end
```

```javascript
// stores/comments.js (implementado pelo developer)
import { defineStore } from 'pinia'
import { commentsApi } from '@/api/comments'

export const useCommentsStore = defineStore('comments', {
  state: () => ({
    comments: []
  }),
  
  actions: {
    async createComment(postId, content) {
      const comment = await commentsApi.create(postId, content)
      this.comments.push(comment)
      return comment
    }
  }
})
```

**Resultado Final:**
```bash
$ bundle exec rspec
# 42 examples, 0 failures ✅

$ npm run test
# Test Suites: 8 passed
# Tests: 24 passed ✅
```

### 🔍 avaliason (Revisor) Output

**Análise de Qualidade**
```
✅ SOLID Principles
  - SRP: Controller skinny, lógica no model
  - OCP: Extensível via callbacks

⚠️  Performance
  - Adicionar eager loading: Comment.includes(:author, :post)
  - Adicionar índices: add_index :comments, [:post_id, :created_at]

✅ Security
  - Authentication OK (before_action :authenticate_user!)
  - Authorization OK (current_user.comments.build)
  - Strong params OK

💡 Sugestões
  - Extrair CommentNotificationService para envio de emails
  - Adicionar scope: scope :recent, -> { order(created_at: :desc) }
```

## 🔧 Personalização

Você pode personalizar os agentes editando:

- Arquivos `.md` dos agentes: Comportamento e instruções
- `knowledge/*.md`: Adicionar ou modificar base de conhecimento
- Adicionar novos arquivos de conhecimento conforme necessário

## 💡 Dicas de Uso

1. **SEMPRE comece com Requison**: Levanta requisitos completos e faz as perguntas certas ⭐
2. **SEMPRE mencione se é projeto existente**: Os agentes analisam e seguem os padrões estabelecidos ⚠️
3. **Não pule a análise de requisitos**: Requisitos mal levantados = retrabalho garantido
4. **Valide os requisitos com Requison**: Confirme que cobriu tudo antes de passar para Ana
5. **Siga a ordem completa**: Requison → Ana → Devoso → Verifier → Avaliason ⭐
6. **Use Verifier após implementação**: Confirme que funciona antes de considerar completo ⭐
7. **Use Better Specs**: Sempre siga os padrões do https://www.betterspecs.org/
8. **Itere quando necessário**: Se requisitos mudarem, volte ao Requison
9. **Confie na equipe**: Requison analisa, Ana planeja, Devoso implementa, Verifier valida, Avaliason revisa
10. **Consistência é chave**: Em projetos existentes, seguir padrões > inventar novos padrões
11. **Documente decisões**: Requison documenta tudo; use isso como referência

## 🤝 Contribuindo

Para melhorar este agente:

1. Adicione novos patterns nos checklists
2. Expanda os exemplos de anti-patterns
3. Adicione novas seções no template
4. Documente learnings de features reais

## 📝 Licença

Este agente é específico do projeto e pode ser customizado conforme necessário.

---

**Rails + Vue.js + TDD + IA = Feature Planning de Qualidade** 🚀
