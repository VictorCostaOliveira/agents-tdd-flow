---
name: test-driven-development-skills
description: Orquestra o pipeline TDD em etapas com skills dedicadas (LAYOUT_SPEC, TESTS.md, testes, DEV.md, REFACTOR.md, AVALIACAO.md), gates de aprovação e ordem doc antes de código. Usar quando o fluxo TDD deve ser seguido lendo uma skill por fase; não usar subagentes Task.
---

# TDD por skills

**Sem subagentes:** não invocar `Task` nem subagentes. Em cada etapa, **abrir e seguir** o `SKILL.md` indicado na tabela.

## Etapas e skills

| # | Skill | Artefato(s) principal(is) |
|---|--------|---------------------------|
| 1 | [`tdd-layout-spec`](../tdd-layout-spec/SKILL.md) | `LAYOUT_SPEC.md` |
| 2a | [`tdd-tests-plan`](../tdd-tests-plan/SKILL.md) | `TESTS.md` (árvore `### A.`… + `text` / describe·context·it) |
| 2b | [`tdd-tests-implement`](../tdd-tests-implement/SKILL.md) | testes novos — **suíte pode falhar**; sem produto nem mínimo para verde |
| 3 | [`tdd-dev`](../tdd-dev/SKILL.md) | `DEV.md` + código até testes verdes |
| 4 | [`tdd-refactor`](../tdd-refactor/SKILL.md) | `REFACTOR.md` + refatoração |
| 5 | [`tdd-avaliacao`](../tdd-avaliacao/SKILL.md) | `AVALIACAO.md` |

## Princípio inviolável

- O **`.md` da etapa** é o **contrato**; o código **materializa** o contrato — nunca o inverso.
- **Ordem no disco:** artefato da fase **gravado por completo** → só depois criar/editar código conforme a etapa.
- **Proibido** na mesma corrida: avançar implementação/refatoração/testes em código **antes** do artefato correspondente existir **gravado** (exceção: leitura para **escrever** o plano).
- **Gate humano** após cada etapa: entregar resumo + paths, **parar**, esperar **aprovação explícita** ou ajustes na mesma etapa.

## Artefatos e gates (resumo)

| # | Entrega | Gate |
|---|---------|------|
| 1 | `LAYOUT_SPEC.md` | Aprovar antes de 2a |
| 2a | só `TESTS.md` | Aprovar antes de 2b |
| 2b | testes novos (vermelho esperado) | Aprovar antes de 3 |
| 3 | `DEV.md` + código (testes verdes) | Aprovar antes de 4 |
| 4 | `REFACTOR.md` + refatoração (ou N/A) | Aprovar antes de 5 |
| 5 | `AVALIACAO.md` | Correções com `tdd-dev`; nova ronda conforme combinado |

**Pasta:** mesma **pasta da feature** para todos os `.md` (ou caminho acordado no contexto).

## Como executar

1. Na etapa em curso, abrir o **`SKILL.md`** correspondente (caminho absoluto ajuda se o workspace não for `~/.cursor/skills`).
2. Executar **só** o que essa skill descreve; **não** misturar etapas num único turno quando o gate proíbe (ex.: 2a e 2b juntos).
3. Se o utilizador pedir esta orquestração explicitamente, **indicar** a skill seguinte e **confirmar** que o artefato anterior foi aprovado.

## Input

- Link Figma (etapa 1), objetivo opcional, critérios de aceite (recomendado ≤5), pasta da feature.

## `TESTS.md` (etapa 2a)

Plano **sempre** no formato de **árvore**: cabeçalhos `### A.`, `### B.`… com nome do suíte entre backticks; dentro, bloco `text` indentado com `describe` / `context` / `it`. Detalhe em **`tdd-tests-plan`** e no agente **`testivos`**. Na **2b**, não implementar feature: testes podem **falhar** até **`tdd-dev`** (ver **`tdd-tests-implement`**).

## Regras rápidas

| Tema | Regra |
|------|--------|
| Testes existentes | Não alterar salvo pedido explícito do utilizador |
| `tdd-dev` / `tdd-refactor` | Não tocar em testes |
| Rails migrations | Não correr nem criar à mão sem regras do projeto/utilizador |
