---
name: tdd-avaliacao
description: Etapa 5 do pipeline TDD por skills: revisão estruturada (diff, requisitos, SOLID) e grava AVALIACAO.md completo na pasta da feature para correção na etapa tdd-dev.
---

# TDD — Etapa 5: `AVALIACAO.md`

**Sem subagentes:** não usar `Task` nem subagentes; executar esta etapa diretamente.

## Artefato obrigatório

**Toda** execução deve persistir **`AVALIACAO.md`** na pasta da feature com **todos** os achados (P0–P3), referências `caminho:linha`, e tabela de cobertura de requisitos quando houver critérios/objetivo no contexto.

- O resumo no chat pode ser curto; a revisão **completa** fica no **`AVALIACAO.md`**.
- **Não** considerar a etapa “entregue” sem **`AVALIACAO.md`** gravado — um resumo longo só no chat **não** substitui o artefato.

## Severidades (resumo)

| Nível | Significado típico |
|-------|---------------------|
| P0 | Correção obrigatória (corretude, requisito crítico falhado) |
| P1 | Alto (lógica, gap forte vs critérios, SOLID grave) |
| P2 | Médio (manutenibilidade, smell) |
| P3 | Baixo (estilo, nitpick) |

## Workflow

1. **Contexto:** `git status`, `git diff` (e `rg`/grep se preciso). Diffs grandes: rever por módulo.
2. **Requisitos vs implementação:** quando houver critérios/LAYOUT/TESTS no contexto, mapear cada um a código e classificar (atendido / parcial / não / fora de escopo).
3. **Qualidade:** tamanho de métodos, complexidade, SOLID, oportunidades de remoção — alinhado a `~/.cursor/agents/knowledge/solid-checklist.md` se existir.
4. **Persistir** `AVALIACAO.md` com findings numerados, severidade, ação sugerida.

**Segurança:** vulnerabilidades e threat modelling em profundidade — fora do âmbito por defeito; tratar noutro passo se o utilizador pedir.

## Pós-revisão

- **`tdd-dev`** lê `AVALIACAO.md` e corrige **sem** alterar testes (salvo autorização explícita).
- **Parar** no gate acordado com o utilizador antes de nova ronda de implementação.

## Edge cases

- **Sem diff:** informar e perguntar se deve rever staged ou intervalo de commits.
- **Sem requisitos no contexto:** declarar e sugerir partilha de critérios para próxima ronda.
