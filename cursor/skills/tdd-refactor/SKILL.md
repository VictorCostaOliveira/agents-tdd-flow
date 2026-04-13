---
name: tdd-refactor
description: Etapa 4 do pipeline TDD por skills: grava REFACTOR.md alinhado a rules/knowledge e só então refatora código mantendo testes verdes. Não altera testes. Se nada a fazer, REFACTOR.md com N/A explícito.
---

# TDD — Etapa 4: `REFACTOR.md` + refatoração

**Sem subagentes:** não usar `Task` nem subagentes; executar esta etapa diretamente.

## Pré-requisitos

- Testes **verdes** após `tdd-dev`.
- Acesso a **`.cursor/rules`**, convenções do repo e, se existirem, `~/.cursor/agents/knowledge/*.md` pertinentes.

## Duas fases

1. **Fase A — `REFACTOR.md`:** plano na pasta da feature — o que remover, simplificar, renomear; riscos; ordem; notas **front vs API** (filtros/paginação no cliente vs contrato HTTP) quando aplicável. Se não houver ação: *N/A — nada a refatorar* com justificativa curta.
2. **Fase B:** aplicar refatoração **só depois** de `REFACTOR.md` gravado; rodar testes do escopo; comportamento externo inalterado.

**Proibido:** editar código de implementação para refatorar **antes** de `REFACTOR.md` no disco (salvo N/A no próprio `REFACTOR.md`).

## Prioridades (checklist)

- Conformidade com rules (naming, i18n, Tailwind, estrutura).
- Complexidade, defesas redundantes, métodos longos — extrair com nomes claros (~15 linhas por método quando praticável).
- Código morto, ramos inalcançáveis.
- Duplicação de convenções já cobertas por rules.

## Proibido

- Alterar testes (`.spec.`, `.test.`, RSpec, etc.).
- Mudar comportamento visível ou contratos sem âmbito acordado (refactor puro = comportamento igual).

## Fim da etapa

- `REFACTOR.md` + código refatorado + testes ainda verdes.
- **Parar** — gate: aprovação antes de **`tdd-avaliacao`**.
