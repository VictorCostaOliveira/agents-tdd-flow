---
name: spec-arquitetura
description: Gera uma SPEC de arquitetura (technical design doc) com 10 áreas fixas — Arquitetura, Fluxos de integração, APIs, Eventos, Modelagem de dados, Observabilidade, Segurança, Resiliência, Plano de rollout, Riscos técnicos. Use ao desenhar um sistema ou serviço novo, uma integração entre serviços ou uma mudança arquitetural grande, ou quando o usuário chamar /spec-arquitetura. Difere da criar-spec, que é spec de produto ou feature.
---

# Spec de arquitetura (technical design doc)

Documento de design técnico que precede a implementação de um **sistema, serviço ou integração**. A `criar-spec` é a spec de produto ou feature, focada em objetivo, comandos, testes e boundaries; esta skill descreve **como o sistema é construído por dentro**.

## Quando usar

- Sistema ou serviço novo do zero
- Integração entre serviços (ex.: API ↔ serviço de autenticação, novo gateway)
- Mudança arquitetural grande (novo evento, nova fila, troca de storage)
- Decisão que afeta múltiplos serviços ou tem trade-off relevante

Feature de UI, bug fix ou mudança contida num único módulo usam a `criar-spec` ou vão direto ao código.

## Como gerar

1. **Levantar o contexto real antes de escrever.** Inspecione o repo afetado: serviços, rotas, modelos, filas e eventos existentes, padrões de observabilidade e de error reporting. A spec descreve o sistema real, e não um genérico.
2. **Delegue o desenho ao agente `arquiteto`** quando houver trade-offs de arquitetura: ele apresenta opções com prós e contras e evita over-engineering. Consolide o retorno no doc.
3. **Preencher só o que se aplica.** Seção sem conteúdo real recebe `N/A — <motivo>` em vez de invenção. Spec honesta vale mais que spec completa.
4. **Suposições à vista.** Liste premissas (volume, SLA, permissões, consistência) e peça confirmação antes de travar.
5. Salve como `SPEC_ARQUITETURA.md` (ou `spec/<feature>/ARQUITETURA.md`) e alinhe com o time antes de implementar.

## Template

```markdown
# Spec de Arquitetura: [Nome do sistema, serviço ou integração]

## Contexto e objetivo
[O que estamos construindo e por quê. Problema, escopo, fora de escopo. Premissas a confirmar.]

## 1. Arquitetura
[Visão geral dos componentes e como se conectam. Diagrama em ASCII se ajudar.
Decisões-chave e alternativas descartadas, com o porquê.]

## 2. Fluxos de integração
[Como este sistema conversa com os outros (síncrono ou assíncrono). Sequência das chamadas
ponta a ponta, contratos entre serviços, dependências externas.]

## 3. APIs
[Endpoints expostos e consumidos: método, path, request e response (envelope, status),
autenticação, idempotência, paginação. Só os que esta mudança cria ou altera.]

## 4. Eventos
[Eventos publicados e consumidos: nome, payload, produtor e consumidor, fila ou tópico,
ordering, retry, dead-letter. N/A sem mensageria.]

## 5. Modelagem de dados
[Tabelas ou coleções novas ou alteradas: colunas, tipos, índices, constraints, relações.
Migrations necessárias (descrever; criar só com pedido). Estratégia de migração de dados.]

## 6. Observabilidade
[Logs (o quê e nível), métricas, traces, dashboards, alertas. Como erros são reportados,
seguindo o padrão do repo. Como saberemos que está saudável em produção.]

## 7. Segurança
[AuthN e AuthZ, dados sensíveis (PII, financeiro), criptografia, escopo de tokens,
superfície de ataque, validação na borda. LGPD quando aplicável.]

## 8. Estratégias de resiliência
[Timeouts, retries com backoff, circuit breaker, fallback, idempotência,
degradação graciosa, o que acontece quando uma dependência cai.]

## 9. Plano de rollout
[Ordem de deploy entre serviços, feature flags, backward compatibility, migração de dados,
rollback. Releases acopladas que precisam ir juntas.]

## 10. Riscos técnicos
[Riscos concretos (performance, consistência, acoplamento, dívida) com impacto,
probabilidade e mitigação. Open questions que precisam de decisão humana.]
```

## Verificação

- [ ] Contexto e objetivo claros, suposições listadas
- [ ] Cada uma das 10 áreas preenchida com fato real do repo **ou** `N/A` justificado
- [ ] Trade-offs de arquitetura passaram pelo agente `arquiteto` quando relevantes
- [ ] Diagramas e contratos refletem serviços reais (nomes, rotas, eventos existentes)
- [ ] Open questions e riscos com mitigação registrados
- [ ] Doc salvo no repo e revisado pelo time antes de codar
