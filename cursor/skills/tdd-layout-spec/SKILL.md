---
name: tdd-layout-spec
description: Etapa 1 do pipeline TDD por skills: analisa Figma via MCP e grava LAYOUT_SPEC.md na pasta da feature. Usar com link Figma e pasta da feature; não cria testes nem código de produto.
---

# TDD — Etapa 1: `LAYOUT_SPEC.md`

**Sem subagentes:** não usar `Task` nem subagentes; executar esta etapa diretamente.

**Entrega:** apenas **`LAYOUT_SPEC.md`** gravado no disco.

## Pré-requisitos

- URL do Figma com `node-id` (ou regras do projeto para branch/Make).
- **Pasta da feature** onde gravar `LAYOUT_SPEC.md`.

## Figma MCP

Server: **`plugin-figma-figma`**. Ver schema das tools no projeto antes de chamar.

1. **Extrair da URL:** `fileKey`; `node-id` da query com **hífen → dois-pontos** (ex. `6600-124999` → `6600:124999`). Branch: usar `branchKey` como `fileKey` quando aplicável.
2. **`get_design_context`:** `fileKey`, `nodeId`; recomendado `clientLanguages: typescript`, `clientFrameworks: vue`. Não excluir screenshot salvo pedido.
3. **`get_screenshot`:** mesmo `fileKey`/`nodeId` se precisar de referência visual extra.

Adaptar output ao **stack do projeto** (ex.: Vue 3, Tailwind, biblioteca UI do repo) — o código gerado pelo MCP é referência, não cópia literal de outro framework.

## Conteúdo de `LAYOUT_SPEC.md`

Documento **conciso e escaneável** na pasta da feature:

1. **Cabeçalho:** título, link Figma completo, `nodeId`, linha de escopo.
2. **Cores:** tabela uso → Figma → classes/tokens do projeto (preferir tokens/preset do repo, evitar hex soltos quando existir token).
3. **Tipografia:** tamanhos, peso, leading (Tailwind ou tokens).
4. **Espaçamentos:** padding, gap, alturas relevantes.
5. **Componentes:** o que reutilizar da lib do projeto vs criar; ícones.
6. **Estados:** loading, erro, vazio, disabled, se visíveis no design.
7. **Notas de implementação:** dependências, breakpoints, acessibilidade se evidente no design.

Não inventar assets; usar MCP/download quando o projeto o previr.

## Fim da etapa

- Gravar **`LAYOUT_SPEC.md`**.
- Resumir + paths.
- **Parar** — gate: aprovação do utilizador antes de **`tdd-tests-plan`**.

## Não fazer nesta etapa

- `TESTS.md`, testes, `DEV.md`, código de produto, `REFACTOR.md`, `AVALIACAO.md`.
