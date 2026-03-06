# Templates

Esta base de conhecimento contém templates reutilizáveis para planejamento de features e remoção de código.

---

## Feature Planning Template

Use this template as a starting point for planning features. Customize based on the specific feature requirements.

---

# Feature: [Feature Name]

## 📋 Overview

### Description
[1-2 paragraph description of what this feature does and why it's needed]

### Goals
- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

### Success Metrics
- **Metric 1**: [How to measure]
- **Metric 2**: [How to measure]

### Stakeholders
- **Product Owner**: [Name]
- **Tech Lead**: [Name]
- **Designer**: [Name]

---

## 🎯 Requirements Analysis

### Functional Requirements
1. **[Requirement Category]**
   - User can [action]
   - System should [behavior]
   - Data must [constraint]

2. **[Another Category]**
   - ...

### Non-Functional Requirements
- **Performance**: [e.g., Page load < 2s]
- **Security**: [e.g., Only authenticated users]
- **Accessibility**: [e.g., WCAG 2.1 AA compliance]
- **Browser Support**: [e.g., Chrome, Firefox, Safari latest 2 versions]
- **Mobile**: [e.g., Responsive down to 320px]

### Out of Scope (for this iteration)
- [Feature/behavior not included]
- [Another excluded item]

---

## 🏗️ Architecture Design

### System Context
```
┌──────────┐      ┌──────────┐      ┌──────────┐
│  Client  │─────▶│ Backend  │─────▶│ Database │
└──────────┘      └──────────┘      └──────────┘
                        │
                        ▼
                  ┌──────────┐
                  │ External │
                  │  Service │
                  └──────────┘
```

### Frontend Architecture

#### Component Hierarchy
```
App
└── FeaturePage
    ├── FeatureHeader
    ├── FeatureContent
    │   ├── SubComponentA
    │   └── SubComponentB
    └── FeatureFooter
```

#### State Management
- **Local State**: [What data is kept in component state]
- **Global State**: [What data goes in Redux/Context]
- **Server State**: [What data is fetched from API]
- **URL State**: [What data is in query params/route]

#### Routing
- `/feature` - Main feature page
- `/feature/:id` - Detail view
- `/feature/create` - Creation form

#### Key Components
1. **ComponentName**
   - **Purpose**: [What it does]
   - **Props**: [List of props and types]
   - **State**: [Internal state if any]
   - **Behavior**: [Key interactions]

### Backend Architecture

#### API Endpoints

##### `POST /api/v1/resource`
**Purpose**: Create a new resource

**Request**:
```json
{
  "field1": "value",
  "field2": 123
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "field1": "value",
    "field2": 123,
    "createdAt": "2026-02-10T10:00:00Z"
  }
}
```

**Errors**:
- `400` - Validation error
- `401` - Unauthorized
- `409` - Resource already exists

##### `GET /api/v1/resource/:id`
**Purpose**: Get a single resource

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "field1": "value",
    "field2": 123
  }
}
```

**Errors**:
- `404` - Resource not found

[Add more endpoints as needed]

#### Service Layer
- **ServiceName**: Handles [business logic description]
  - `methodName(params)`: [What it does]
  - `anotherMethod(params)`: [What it does]

#### Repository Layer
- **RepositoryName**: Data access for [entity]
  - `findById(id)`
  - `findAll(filters)`
  - `create(data)`
  - `update(id, data)`
  - `delete(id)`

### Data Model

#### Database Schema

##### `table_name`
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| field1 | VARCHAR(255) | NOT NULL | Description |
| field2 | INTEGER | | Description |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() ON UPDATE NOW() | Last update |

**Indexes**:
- `idx_table_field1` on `field1` (for lookups)
- `idx_table_created_at` on `created_at` (for sorting)

**Relationships**:
- Belongs to `other_table` via `other_table_id`
- Has many `related_table`

#### Entity Relationships
```
┌─────────────┐       ┌─────────────┐
│   Entity A  │───────│   Entity B  │
│             │  1:N  │             │
└─────────────┘       └─────────────┘
```

#### Migrations
```sql
-- Migration: add_feature_table
CREATE TABLE feature_table (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  field1 VARCHAR(255) NOT NULL,
  field2 INTEGER,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_feature_field1 ON feature_table(field1);
```

---

## 📐 Detailed Design

### User Flows

#### Flow 1: [Primary User Flow]
1. User navigates to `/feature`
2. System loads data from API
3. User interacts with [component]
4. System validates input
5. API call to create/update resource
6. Success message displayed
7. User redirected to [destination]

#### Flow 2: [Secondary User Flow]
...

### Wireframes / UI Mockups
[Link to Figma/design tool or ASCII mockup]

```
┌──────────────────────────────────────┐
│  Header                              │
├──────────────────────────────────────┤
│                                      │
│  [Feature Content Area]              │
│                                      │
│  ┌────────────┐  ┌────────────┐     │
│  │ Component  │  │ Component  │     │
│  │     A      │  │     B      │     │
│  └────────────┘  └────────────┘     │
│                                      │
├──────────────────────────────────────┤
│  Footer                              │
└──────────────────────────────────────┘
```

### Validation Rules
- **Field1**: Required, min 3 chars, max 100 chars
- **Field2**: Optional, must be positive integer
- **Email**: Required, valid email format
- **Business Rule**: [Custom validation logic]

### Error Handling
- **Network Error**: Show retry button, queue for retry
- **Validation Error**: Display inline errors next to fields
- **Server Error**: Show generic error message, log details
- **Not Found**: Redirect to 404 page

---

## 🔄 Implementation Plan

### Phase 1: Database & Backend Foundation
**Estimated effort**: [X hours/days]

- [ ] Create database migration
- [ ] Create model/entity classes
- [ ] Implement repository layer
- [ ] Add database indexes
- [ ] Test with seed data

**Files to create/modify**:
- `migrations/XXXX_create_feature_table.sql`
- `models/Feature.js`
- `repositories/FeatureRepository.js`

### Phase 2: Backend Business Logic
**Estimated effort**: [X hours/days]

- [ ] Implement service layer
- [ ] Add validation logic
- [ ] Implement business rules
- [ ] Add error handling
- [ ] Write unit tests for services

**Files to create/modify**:
- `services/FeatureService.js`
- `validation/featureSchema.js`
- `tests/services/FeatureService.test.js`

### Phase 3: API Endpoints
**Estimated effort**: [X hours/days]

- [ ] Create controllers
- [ ] Define routes
- [ ] Add authentication middleware
- [ ] Implement request/response formatting
- [ ] Write integration tests

**Files to create/modify**:
- `controllers/FeatureController.js`
- `routes/feature.routes.js`
- `tests/integration/feature.test.js`

### Phase 4: Frontend Components
**Estimated effort**: [X hours/days]

- [ ] Create base components
- [ ] Implement form components
- [ ] Add validation
- [ ] Connect to API
- [ ] Handle loading/error states
- [ ] Write component tests

**Files to create/modify**:
- `components/Feature/FeaturePage.jsx`
- `components/Feature/FeatureForm.jsx`
- `components/Feature/FeatureList.jsx`
- `tests/components/Feature.test.jsx`

### Phase 5: Frontend State & Integration
**Estimated effort**: [X hours/days]

- [ ] Set up state management
- [ ] Implement API integration
- [ ] Add caching strategy
- [ ] Handle optimistic updates
- [ ] Add error boundaries

**Files to create/modify**:
- `store/featureSlice.js`
- `api/featureApi.js`
- `hooks/useFeature.js`

### Phase 6: Styling & Polish
**Estimated effort**: [X hours/days]

- [ ] Implement responsive design
- [ ] Add animations/transitions
- [ ] Ensure accessibility
- [ ] Cross-browser testing
- [ ] Performance optimization

**Files to create/modify**:
- `styles/Feature.module.css`

### Phase 7: Testing & Documentation
**Estimated effort**: [X hours/days]

- [ ] Write E2E tests
- [ ] Update API documentation
- [ ] Write user documentation
- [ ] Code review
- [ ] QA testing

**Files to create/modify**:
- `cypress/e2e/feature.cy.js`
- `docs/api/feature.md`
- `docs/user/feature-guide.md`

---

## ⚠️ Considerations & Risks

### Security Considerations
- [ ] **Authentication**: [How users are authenticated]
- [ ] **Authorization**: [Permission checks]
- [ ] **Input Validation**: [Sanitization strategy]
- [ ] **SQL Injection**: [Use parameterized queries]
- [ ] **XSS Prevention**: [Escape output]
- [ ] **CSRF Protection**: [Token strategy]
- [ ] **Rate Limiting**: [Prevent abuse]

### Performance Considerations
- [ ] **Database**: Index on frequently queried columns
- [ ] **Caching**: Cache expensive queries for [X] minutes
- [ ] **Pagination**: Limit to [X] items per page
- [ ] **Lazy Loading**: Load images/components on demand
- [ ] **Code Splitting**: Separate bundle for feature
- [ ] **API Response Time**: Target < 200ms

### Scalability Considerations
- [ ] Expected load: [X] requests/second
- [ ] Data growth: [X] records per day
- [ ] Horizontal scaling strategy
- [ ] Database sharding/partitioning plan

### Edge Cases to Handle
1. **Empty State**: What to show when no data
2. **Maximum Limits**: What happens at max capacity
3. **Concurrent Edits**: How to handle conflicts
4. **Network Failure**: Retry strategy
5. **Invalid Data**: Graceful degradation
6. **Partial Failures**: Transaction handling

### Dependencies
- **Internal**: [Other features/services this depends on]
- **External**: [Third-party APIs/services]
- **Libraries**: [New packages needed]

### Rollback Plan
If the feature needs to be rolled back:
1. [Step to disable feature flag / route]
2. [Step to rollback database migration if needed]
3. [Step to restore previous version]

---

## 🧪 Testing Strategy

### Unit Tests
- [ ] Service methods
- [ ] Validation functions
- [ ] Utility functions
- [ ] React hooks
- **Target Coverage**: 80%+

### Integration Tests
- [ ] API endpoints (request/response)
- [ ] Database operations
- [ ] Authentication/authorization
- [ ] Error scenarios

### E2E Tests
- [ ] Critical user flows
- [ ] Form submission
- [ ] Error handling
- [ ] Edge cases

### Manual Testing Checklist
- [ ] Happy path works
- [ ] Error states display correctly
- [ ] Responsive on mobile/tablet/desktop
- [ ] Accessibility (keyboard navigation, screen reader)
- [ ] Cross-browser (Chrome, Firefox, Safari, Edge)
- [ ] Performance acceptable

---

## 🚀 Deployment & Monitoring

### Deployment Steps
1. Run database migrations
2. Deploy backend code
3. Deploy frontend code
4. Run smoke tests
5. Enable feature flag (if applicable)
6. Monitor error rates

### Monitoring & Alerts
- [ ] API response time metrics
- [ ] Error rate tracking
- [ ] Database query performance
- [ ] User engagement metrics
- [ ] Alert if error rate > 5%

### Rollout Strategy
- **Phase 1**: Internal team (10% traffic)
- **Phase 2**: Beta users (25% traffic)
- **Phase 3**: Full rollout (100% traffic)

---

## 📚 Reference Patterns & Principles Applied

### Design Patterns Used
- **Repository Pattern**: Data access abstraction
- **Service Layer Pattern**: Business logic separation
- **Factory Pattern**: [If applicable]
- **Strategy Pattern**: [If applicable]

### SOLID Principles
- **SRP**: Each service/component has single responsibility
- **OCP**: Extensible without modification
- **DIP**: Depend on abstractions (interfaces/repos)

### Best Practices
- Separation of concerns
- DRY (Don't Repeat Yourself)
- Clear error messages
- Comprehensive logging
- Security by default

---

## 📝 Notes & Open Questions

### Open Questions
- [ ] Question 1: [Needs decision/clarification]
- [ ] Question 2: [Needs decision/clarification]

### Technical Debt
- [Any shortcuts taken that need future work]

### Future Enhancements
- [Ideas for future iterations]
- [Nice-to-have features not in scope]

---

## ✅ Definition of Done

Feature is considered complete when:
- [ ] All implementation phases completed
- [ ] Unit tests pass (80%+ coverage)
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Accessibility requirements met
- [ ] Performance targets met
- [ ] Security review passed
- [ ] QA testing completed
- [ ] Deployed to production
- [ ] Monitoring in place
- [ ] Stakeholders signed off

---

**Last Updated**: [Date]
**Status**: [Draft / In Progress / Ready for Development / Complete]

---
---

## Code Removal Plan Template

Use este template para planejar remoção segura de código morto ou legacy.

## Identificando Candidatos

### Código Morto
- Métodos nunca chamados (verificar com `rg "method_name"`)
- Classes não instanciadas
- Rotas sem requests (verificar logs/analytics)
- Views não renderizadas
- Migrations antigas já executadas
- Gems não usadas

### Feature Flags Desabilitados
```ruby
# Se feature flag sempre false:
def experimental_feature
  return unless FeatureFlag.enabled?(:experiment)  # Sempre false
  # código aqui nunca executa
end
```

### Código Legacy/Deprecated
- Integrações com serviços descontinuados
- Versões antigas de APIs
- Workarounds para bugs já corrigidos
- Código comentado

## Template de Análise

Para cada candidato à remoção, preencha:

### 1. Identificação

| Campo | Valor |
|-------|-------|
| **Arquivo/Classe/Método** | `app/services/legacy_payment_service.rb` |
| **Tipo** | Service Object legacy |
| **Linhas de código** | ~200 linhas |
| **Último uso conhecido** | 6 meses atrás |
| **Feature flag?** | Não |

### 2. Análise de Impacto

**Dependências identificadas:**
```bash
# Buscar referências:
rg "LegacyPaymentService" --type ruby

# Resultados:
# - spec/services/legacy_payment_service_spec.rb (testes)
# - config/initializers/payment.rb (comentado)
# - Nenhuma referência em código ativo
```

**Áreas de risco:**
- [ ] Controllers/Views
- [ ] Background jobs
- [ ] Rake tasks
- [ ] Scripts de deploy
- [ ] APIs externas
- [ ] Webhooks
- [ ] Scheduled jobs (cron)

**Impacto estimado:**
- 🟢 Baixo - Nenhuma dependência ativa encontrada
- 🟡 Médio - Algumas dependências mas alternativa existe
- 🔴 Alto - Dependências críticas ou sem alternativa

### 3. Estratégia de Remoção

#### Opção A: Remoção Imediata (Seguro)

Quando usar:
- ✅ Nenhuma referência encontrada
- ✅ Código nunca executado (logs confirmam)
- ✅ Feature flag permanentemente desabilitada
- ✅ Testes passam sem o código

**Plano:**
1. Criar PR de remoção
2. Incluir busca de referências no PR description
3. Deploy em staging
4. Smoke tests
5. Deploy em produção
6. Monitorar logs por 24h

#### Opção B: Deprecation + Remoção (Defer)

Quando usar:
- ⚠️ Referências encontradas mas mínimas
- ⚠️ Uso incerto (logs insuficientes)
- ⚠️ Código ainda ativo mas tem replacement
- ⚠️ Integrações externas podem depender

**Plano - Fase 1: Deprecation (Sprint 1)**
```ruby
class LegacyPaymentService
  def self.process(order)
    Rails.logger.warn "[DEPRECATION] LegacyPaymentService is deprecated. Use NewPaymentService instead."
    DeprecationTracker.log('LegacyPaymentService.process')
    
    # código existente...
  end
end
```

**Plano - Fase 2: Monitoring (Sprints 2-3)**
- Monitorar DeprecationTracker
- Verificar logs de uso
- Notificar stakeholders se uso detectado
- Migrar últimos casos de uso

**Plano - Fase 3: Remoção (Sprint 4)**
- Se zero uso por 2 sprints → remover
- Criar PR seguindo Opção A

#### Opção C: Migration + Remoção (Complexo)

Quando usar:
- 🔴 Código ativo com muitas dependências
- 🔴 Replacement existe mas requer migração
- 🔴 Dados precisam ser migrados

**Plano:**

**Sprint 1: Preparação**
- [ ] Criar replacement (NewPaymentService)
- [ ] Adicionar testes paralelos (old vs new)
- [ ] Feature flag para toggle

**Sprint 2: Migration**
- [ ] Migrar código novo para usar NewPaymentService
- [ ] Manter LegacyPaymentService como fallback
- [ ] Logs comparativos (old vs new behavior)

**Sprint 3: Rollout**
- [ ] Feature flag 10% → 50% → 100%
- [ ] Monitorar errors e rollback se necessário
- [ ] Corrigir edge cases

**Sprint 4: Cleanup**
- [ ] Remover LegacyPaymentService
- [ ] Remover feature flag
- [ ] Update documentação

### 4. Rollback Plan

Se algo der errado após remoção:

```bash
# Opção 1: Git revert
git revert <commit-hash>
git push

# Opção 2: Revert PR no GitHub
# (UI do GitHub tem botão "Revert")

# Opção 3: Emergency hotfix
# - Restaurar arquivo deletado do git history
# - Criar PR de emergency
```

**Critérios para rollback:**
- Errors em produção relacionados
- Funcionalidade quebrada
- Requests falhando
- Jobs falhando
- Stakeholder reporta problema

### 5. Checklist de Execução

Antes de remover:
- [ ] Busquei todas as referências? (`rg`, `ag`, `grep`)
- [ ] Verifiquei background jobs? (Sidekiq, delayed_job)
- [ ] Verifiquei rake tasks?
- [ ] Verifiquei scripts de deploy?
- [ ] Verifiquei cron jobs?
- [ ] Verifiquei APIs externas/webhooks?
- [ ] Testes passam sem o código?
- [ ] Logs não mostram uso recente?
- [ ] Stakeholders foram notificados?
- [ ] Rollback plan documentado?

Durante remoção:
- [ ] PR criado com contexto completo
- [ ] Code review por senior dev
- [ ] Deploy em staging primeiro
- [ ] Smoke tests em staging
- [ ] Deploy em horário de baixo tráfego
- [ ] Monitoramento ativo após deploy

Após remoção:
- [ ] Logs monitorados por 24-48h
- [ ] Nenhum erro relacionado
- [ ] Metrics estáveis
- [ ] Documentação atualizada
- [ ] Update CHANGELOG

## Exemplos de Removal Plans

### Exemplo 1: Método Não Usado (Remoção Segura)

```markdown
**Candidato**: `User#legacy_notification_preferences`

**Análise**:
- Último uso: > 1 ano (migration completa para new system)
- Referências: Apenas specs (que também serão removidos)
- Risco: 🟢 Baixo

**Plano**: Remoção imediata
- Remover método
- Remover specs
- Remover migration antiga (se > 1 ano)

**PR**: #1234 - Remove legacy notification preferences
```

### Exemplo 2: Feature Flag Off (Deprecation)

```markdown
**Candidato**: `ExperimentalSearchService`

**Análise**:
- Feature flag `:new_search` sempre false há 6 meses
- Replacement: `SearchService` (ativo e estável)
- Referências: 3 controllers ainda tem código condicional
- Risco: 🟡 Médio

**Plano**: Deprecation (2 sprints) → Remoção

**Sprint 1**: 
- Adicionar deprecation warnings
- Notificar team no Slack
- Monitorar logs

**Sprint 2**:
- Remover feature flag
- Remover código condicional
- Remover ExperimentalSearchService
```

### Exemplo 3: Integração Legacy (Migration Complexa)

```markdown
**Candidato**: `OldPaymentGateway` (integração com gateway descontinuado)

**Análise**:
- 5 clientes ainda usam
- Replacement: `NewPaymentGateway` (pronto e testado)
- Risco: 🔴 Alto (pagamentos críticos)

**Plano**: Migration em 4 sprints

**Sprint 1**: Preparação
- Contatar 5 clientes para migração
- Documentar processo de migração
- Criar ferramentas de migração

**Sprint 2-3**: Migração
- Migrar 1 cliente por semana
- Suporte dedicado durante migração
- Monitorar transações

**Sprint 4**: Remoção
- Após todos migrarem → deprecate
- 1 sprint de buffer
- Remover código
```

## Anti-patterns a Evitar

### ❌ Comentar ao invés de deletar
```ruby
# def old_method
#   # ...
# end
```
**Problema**: Código comentado polui codebase. Git history já preserva.

### ❌ Remover sem verificar dependências
```ruby
# Remove classe sem buscar referências
# rm app/services/payment_service.rb
# → Quebra produção
```

### ❌ Remover tudo de uma vez
```ruby
# PR gigante com 50 arquivos removidos
# → Difícil review, alto risco
```

### ❌ Sem rollback plan
```
# Remove código crítico sem plano B
# → Se quebrar, scramble para recuperar
```

## Conclusão

Remoção de código deve ser:
- ✅ **Planejada**: Análise de impacto completa
- ✅ **Incremental**: Remover aos poucos, não tudo de uma vez
- ✅ **Reversível**: Sempre ter rollback plan
- ✅ **Monitorada**: Observar impacto após remoção
- ✅ **Comunicada**: Stakeholders informados

> "Código que não existe não tem bugs. Mas remova com cuidado."
