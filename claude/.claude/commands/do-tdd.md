---
description: Pipeline TDD por skills (Figma → testes → dev → refatoração → avaliação): uma skill por etapa, sem subagentes Task.
---

## Diretivas obrigatórias (este comando)

1. **Não use `Task` nem subagentes.** Em cada etapa, **ler e aplicar** o `SKILL.md` da fase (ver tabela abaixo).
2. **Peça validação do artefato ao utilizador antes de seguir** — após cada entrega, **parar**, resumo + paths, só continuar com **aprovação explícita**.
3. **Artefato antes da execução:** o `.md` da fase gravado define o trabalho; proibido codificar primeiro e documentar depois.
4. **Plano de testes em dois passos:** primeiro só `TESTS.md` em **árvore** (`tdd-tests-plan`); após aprovação, `tdd-tests-implement`: specs reais **sem** produto nem atalho para verde — **vermelho** até `tdd-dev` implementar.

## Skill orquestradora

Leia e aplique **`test-driven-development-skills`**:

- `~/.cursor/skills/test-driven-development-skills/SKILL.md`

## Skills por etapa

| Etapa | Skill | Artefato principal |
|-------|--------|-------------------|
| 1 | `tdd-layout-spec` | `LAYOUT_SPEC.md` |
| 2a | `tdd-tests-plan` | `TESTS.md` |
| 2b | `tdd-tests-implement` | testes novos |
| 3 | `tdd-dev` | `DEV.md` + código |
| 4 | `tdd-refactor` | `REFACTOR.md` + código |
| 5 | `tdd-avaliacao` | `AVALIACAO.md` |

Use o pedido do utilizador (Figma, objetivo, critérios, pasta da feature) como input; se faltar o essencial, pergunte antes de avançar.
