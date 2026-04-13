---
name: tdd-tests-implement
description: "Etapa 2b do pipeline TDD por skills: traduz TESTS.md para arquivos de teste reais; suíte deve ficar vermelha até tdd-dev — sem código de produto nem atalhos para verde. Não grava TESTS.md na mesma corrida salvo correção pontual; não altera testes existentes salvo pedido explícito."
---

# TDD — Etapa 2b: testes em código

**Sem subagentes:** não usar `Task` nem subagentes; executar esta etapa diretamente.

## Pré-requisitos

- **`TESTS.md`** já existe no disco, foi **aprovado** pelo utilizador e segue o **formato de árvore** (`### A.`… + bloco `text` com describe/context/it), conforme **`tdd-tests-plan`**.
- `LAYOUT_SPEC.md` e critérios como contexto.

## Obrigatório

1. **Traduzir** cada nó do `TESTS.md` para a sintaxe real (**Vitest**, **Jest**, **RSpec**, etc.): imports, `mount`, factories, matchers — mantendo **estrutura e intenção** do plano; não “inventar” suites que não estão na árvore sem alinhar com o utilizador.
2. **Não** alterar testes pré-existentes; apenas **adicionar** os novos previstos no plano.
3. Se o projeto tiver rule de testing (ex. `.cursor/rules/*testing*`), seguir como fonte de verdade para CLI, globs e estilo.

## Vermelho nesta etapa (TDD)

- **Objetivo:** após esta fase, correr os testes novos deve **falhar** (comportamento ainda não implementado) — isso é **correto**. Quem deixa a suíte **verde** é **`tdd-dev`** (código de produção).
- **Proibido:** criar ou editar **código de produção** (componentes, composables, services, models, etc.) só para satisfazer os specs; stubs mínimos em arquivos de feature; `test.skip` / `xit` / `pending` para esconder falha; mocks que sempre retornam sucesso; asserts vazios ou `expect(true)` para “passar”.
- **Permitido:** falhas por import inexistente, expectativa não atendida, componente ainda não comportando como no design — o que **`tdd-dev`** vai resolver.

## Quando executar

- **Só** depois do gate humano entre 2a e 2b (aprovação do plano).
- **Não** executar Fase B no **mesmo** turno em que acabaste de criar `TESTS.md` (salvo a mensagem do utilizador aprovar explicitamente o plano **nessa** mensagem ou pedir só Fase B).

## Fim da etapa

- Entregar os novos testes + paths.
- **Parar** — gate: aprovação antes de **`tdd-dev`**.

## Não fazer

- Código de produção ou “mínimo para verde” (isso é **`tdd-dev`** — e lá sim até os testes passarem).
- Pular `TESTS.md` no disco em fluxos TDD (o plano já deve existir de 2a).
