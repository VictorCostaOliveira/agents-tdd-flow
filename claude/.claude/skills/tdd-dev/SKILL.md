---
name: tdd-dev
description: Etapa 3 do pipeline TDD por skills: grava DEV.md com plano alinhado aos testes e só então implementa até todos passarem. Nunca altera testes salvo pedido explícito do utilizador.
---

# TDD — Etapa 3: `DEV.md` + implementação

**Sem subagentes:** não usar `Task` nem subagentes; executar esta etapa diretamente.

**Entrada típica:** testes criados em 2b podem estar **vermelhos** (feature ainda inexistente) — **aqui** implementa-se produção até ficarem **verdes**, sem enfraquecer os specs.

## Princípio em duas fases

1. **Fase A — `DEV.md`:** ler **`TESTS.md`**, os testes novos no repo e `LAYOUT_SPEC.md` se existir. Escrever **`DEV.md`** na pasta da feature: o que criar/alterar, métodos/composables principais, ordem sugerida (alinhada a testes a passar), dependências, chaves i18n se necessário.
2. **Fase B — código:** só **depois** de `DEV.md` estar **gravado**, alterar código de produção até **todos** os testes relevantes passarem.

**Proibido:** criar/editar código de implementação **antes** de existir **`DEV.md`** válido no disco para esta ronda. Backfill de `DEV.md` após codar é inválido neste fluxo.

## Após `tdd-avaliacao`

- Ler **`AVALIACAO.md`** e aplicar correções em estilo Fase B; atualizar `DEV.md` se o plano mudar de forma material.
- Continuar a **não** alterar testes.

## Regras absolutas

- **Nunca** alterar, apagar ou comentar testes para “facilitar” — o código é que se ajusta ao contrato dos testes.
- Antes de grandes mudanças, **inspecionar** padrões do repo (pastas, naming, rules em `.cursor/rules`).
- Correr testes do escopo após alterações relevantes até ficarem verdes.

## Fim da etapa

- `DEV.md` + código (testes verdes).
- **Parar** — gate: aprovação antes de **`tdd-refactor`**.

## Não editar por defeito

- `LAYOUT_SPEC.md`, `TESTS.md`, specs de teste; outros docs só se o utilizador pedir.
