# Template de plano de remoção

## Prioridade

- [ ] **P0:** remover já (risco de segurança, custo relevante, bloqueia outro trabalho)
- [ ] **P1:** remover na sprint atual
- [ ] **P2:** backlog / próxima iteração

---

## Seguro remover agora

### Item: [nome ou descrição]

| Campo | Detalhe |
|-------|---------|
| **Local** | `caminho/do/arquivo.rb:linha` |
| **Motivo** | Por que deve sair |
| **Evidência** | Sem referências, feature flag morta, API descontinuada |
| **Impacto** | Nenhum / baixo, sem consumidores ativos |
| **Passos** | 1. Remover código 2. Remover testes 3. Remover config |
| **Verificação** | Rodar testes, conferir que nada quebra em runtime, observar logs |

---

## Adiar remoção (exige plano)

### Item: [nome ou descrição]

| Campo | Detalhe |
|-------|---------|
| **Local** | `caminho/do/arquivo.rb:linha` |
| **Por que adiar** | Consumidores ativos, exige migração, aprovação de stakeholder |
| **Pré-condições** | Feature flag desligada há 2 semanas, telemetria com uso zero |
| **Quebras de contrato** | Mudanças de API ou contrato |
| **Plano de migração** | Passos para os consumidores migrarem |
| **Prazo** | Data ou sprint alvo |
| **Responsável** | Pessoa ou time |
| **Validação** | Métricas que confirmam a remoção segura (erros, contagem de uso) |
| **Rollback** | Como restaurar se der problema |

---

## Checklist antes de remover

- [ ] Buscou todas as referências no código (`rg`, `grep`)
- [ ] Conferiu uso dinâmico ou por reflexão
- [ ] Confirmou que não há consumidor externo (APIs, SDKs, docs)
- [ ] Revisou telemetria da feature flag, se houver
- [ ] Testes atualizados ou removidos
- [ ] Documentação atualizada
- [ ] Time avisado, se o código for compartilhado
