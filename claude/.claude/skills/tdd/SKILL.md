---
name: tdd
description: Implementa funcionalidade a partir de Figma e critérios de aceite em 4 etapas com artefatos obrigatórios por agente — LAYOUT_SPEC.md (figoso), TESTS.md + testes (testivos), DEV.md + código (devoso), AVALIACAO.md (avaliason). Use com link Figma, objetivo/critérios e fluxo TDD completo.
---

# Figma + Critérios de Aceite + TDD

Implementa uma **funcionalidade** (tela ou bloco de UI) com **pipeline fixo de artefatos**: cada agente **sempre** entrega um documento (ou documento + código) **nesta ordem**, sem pular etapas. Isso vale **sempre** — invocado por esta skill **ou** chamada direta a qualquer um dos agentes (`figoso`, `testivos`, `devoso`, `avaliason`).

## Artefatos por etapa (obrigatórios)

| Etapa | Agente | Artefato(s) | Ordem de trabalho |
|-------|--------|---------------|---------------------|
| 1 | **figoso** | **`LAYOUT_SPEC.md`** | Único entregável desta etapa (layout + estrutura de componentes). |
| 2 | **testivos** | **`TESTS.md`** → depois **arquivos de teste** (`.spec.` / `.test.`) | **Primeiro** escrever `TESTS.md` com todos os cenários (mapeando critérios de aceite + `LAYOUT_SPEC.md`/Figma). **Depois** implementar os testes no código. |
| 3 | **devoso** | **`DEV.md`** → depois **código** | **Primeiro** escrever `DEV.md` com planejamento (arquivos, métodos, ordem) **com base nos testes** existentes. **Depois** implementar até todos passarem, **sem alterar testes**. |
| 4 | **avaliason** | **`AVALIACAO.md`** | **Primeiro** analisar o diff/código. **Depois** persistir **todos** os pontos levantados em `AVALIACAO.md` para o **devoso** ler e corrigir. |

**Onde salvar:** na **pasta da feature** (mesmo diretório do `LAYOUT_SPEC.md` ou pasta acordada no contexto). Nomes fixos: `LAYOUT_SPEC.md`, `TESTS.md`, `DEV.md`, `AVALIACAO.md`.

## Input necessário

- **Link do Figma** do nó/tela
- **Objetivo** (opcional, uma frase)
- **Critérios de aceite** (recomendado máx. 5), testáveis

## Fluxo em 4 etapas (detalhado)

### 1. Figoso → `LAYOUT_SPEC.md`

- Invocar **figoso** (`.claude/agents/figoso.md`).
- Input: link do Figma + pasta da feature.
- Saída obrigatória: **`LAYOUT_SPEC.md`** (MCP `get_design_context` / `get_screenshot`, tokens, estrutura de componentes).
- Não inventar assets; preferir download via MCP quando existir.

### 2. Testivos → `TESTS.md` **antes** dos testes no código

- Invocar **testivos** (definição em `.claude/agents/testivos.md`; use o subagente/persona equivalente no Claude Code).
- Contexto: objetivo, critérios de aceite, `LAYOUT_SPEC.md` + estrutura de componentes.
- **Fluxo obrigatório do testivos:**
  1. **Planejar cenários** a partir dos critérios e do layout (estados, interações, edge cases).
  2. **Escrever `TESTS.md`** listando **todos** os cenários/specs que serão codificados (describe/context/it planejados ou equivalente).
  3. **Só então** criar/editar arquivos de teste reais (Vitest + @vue/test-utils, etc.).
- **Não** alterar testes **já existentes** do projeto; apenas adicionar novos.
- Entrega da etapa: **`TESTS.md`** + arquivos de teste novos.

### 3. Devoso → `DEV.md` **antes** da implementação

- Invocar **devoso** (definição em `.claude/agents/devoso.md`).
- Contexto: critérios, `LAYOUT_SPEC.md`, **`TESTS.md`**, paths dos arquivos de teste criados.
- **Fluxo obrigatório do devoso:**
  1. **Ler** testes e `TESTS.md`.
  2. **Escrever `DEV.md`**: arquivos a criar/alterar, métodos/funções principais, ordem sugerida (alinhada aos testes).
  3. **Só então** implementar código até **todos** os testes passarem, **sem alterar testes**.
- Entrega da etapa: **`DEV.md`** + código.

### 4. Avaliason → `AVALIACAO.md`

- Invocar **avaliason** após a implementação.
- **Fluxo obrigatório do avaliason:**
  1. Revisar mudanças (git diff / escopo combinado).
  2. **Escrever `AVALIACAO.md`** com **todos** os pontos (severidade, arquivo, sugestão), no mesmo espírito do formato de review do agente — documento único para o devoso consumir.
  3. O **devoso** (nova invocação se necessário) lê **`AVALIACAO.md`** e aplica correções **sem alterar testes**, até fechar os itens acordados.

### IMPORTANTE

- **Todos** os subagentes **devem** ser chamados em sequência. Se a invocação falhar, **tentar de novo**. Não substituir o trabalho do agente “na mão” quando esta skill estiver ativa.
- **Nunca** pular: `TESTS.md` antes dos testes; `DEV.md` antes do código; `AVALIACAO.md` como registro completo da revisão.
- **Figoso** → somente `LAYOUT_SPEC.md` como artefato de spec de layout.
- **Testivos** e **devoso** seguem o **mesmo padrão em duas fases**: **documento de planejamento primeiro**, **código depois**.
- TDD: fazer testes passarem um a um (ou em lotes coerentes), refatorar com segurança, repetir.

## Regras rápidas

| Regra | Valor |
|-------|--------|
| Textos visíveis | Sempre i18n (pt-BR); nunca hardcoded |
| Estilos | Tailwind; tokens do preset; sem `<style scoped>` |
| Componentes | Reutilizar `@acme/ui` quando existir equivalente |
| Testes | Não alterar testes existentes; testivos cria novos; devoso só implementa |
| Naming | PascalCase componentes; props/emits camelCase; i18n snake_case |

## Referências

- Agentes: **figoso**, **testivos**, **devoso**, **avaliason** (`.claude/agents/*.md`) — cada um com fluxo **doc primeiro → execução**.
- Skills: `figma-design-system`, `figma-objetivos-criterios`, `testing`, `vue-components`, `folder-structure`, `ui-library`
- Exemplo de layout: `apps/web/src/components/orders/OrderList/LAYOUT_SPEC.md`
