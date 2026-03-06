---
name: figma-criterios-tdd
description: Implementa uma funcionalidade a partir de um link do Figma e critérios de aceite: levanta specs visuais via Figma MCP, depois cria testes (testivos) e implementa em TDD (devoso). Use quando o usuário tiver um link do Figma, objetivo/critérios de aceite e quiser testes primeiro e implementação em seguida.
---

# Figma + Critérios de Aceite + TDD

Implementa uma **funcionalidade** (qualquer tela ou bloco de UI) a partir de um design no Figma: levanta especificações visuais via MCP, cria testes com base nos critérios de aceite e implementa até os testes passarem.

## Input necessário

- **Link do Figma** da tela ou do nó (ex.: `https://www.figma.com/design/AbC123xYz456DeF789gHi0/...?node-id=1234-5678`)
- **Objetivo** (opcional, uma frase): o que a funcionalidade deve permitir ao usuário
- **Critérios de aceite** (recomendado máx. 5): testáveis; servem de base para os testes e para a implementação

## Fluxo em 4 etapas

### 1. Levantar specs do Figma (layout)

- Extrair da URL: `fileKey` (path do design) e `nodeId` (parâmetro `node-id` com hífen → dois-pontos, ex. `1234-5678` → `1234:5678`).
- Chamar **Figma MCP** (`plugin-figma-figma`):
  - `get_design_context` com `fileKey`, `nodeId` e opcionalmente `clientLanguages: "typescript"`, `clientFrameworks: "vue"`.
  - `get_screenshot` para referência visual.
- Produzir um **arquivo de spec de layout** na pasta da feature (ex.: `LAYOUT_SPEC.md`) com:
  - **Cores**: mapear para tokens Tailwind do projeto (ver skill `figma-design-system` e preset `@acme/ui`).
  - **Tipografia**: tamanhos de fonte, line-height, peso (ex.: `text-sm`, `text-xs`).
  - **Espaçamentos**: padding, margin, alturas de linhas/blocos.
  - **Componentes visuais**: botões, inputs, badges, tabelas, etc., conforme o design.
- Manter o spec conciso; referenciar o link do Figma no topo.

### 2. Definir estrutura de componentes

- Analisar o design e o **contexto onde a feature será inserida** (página existente, rota, módulo).
- Decidir **quais componentes criar** e onde vivem (views, components por domínio), seguindo `folder-structure` e `vue-components`.
- Se houver padrão similar no projeto (ex.: outra listagem, outro formulário), reutilizar a mesma estrutura de pastas e nomes.
- Documentar brevemente: página/rota que usa a feature, componentes novos e responsabilidade de cada um (sem forçar um único padrão como "só listagem").

### 3. Criar testes (testivos)

- Chamar o **subagente testivos** (`mcp_task` com `subagent_type: "testivos"`).
- Entregar como contexto:
  - **Objetivo** e **critérios de aceite** (input do usuário).
  - Onde a feature fica (página, rotas) e **quais componentes** foram definidos no passo 2.
  - O **arquivo de spec de layout** (ou resumo) para alinhar expectativas visuais.
- Instruir: criar testes (Vitest + @vue/test-utils) que validem os critérios de aceite; seguir convenções do projeto (describe/context/it, helpers de mount do app).
- **Não** alterar testes existentes; apenas criar novos.

### 4. Implementar conforme testes (devoso)

- Chamar o **subagente devoso** (`mcp_task` com `subagent_type: "devoso"`).
- Entregar como contexto:
  - Objetivo e critérios de aceite.
  - Estrutura de componentes (passo 2) e spec de layout (passo 1).
  - Que os **testes já foram criados** pelo testivos e que a implementação deve fazer **todos os testes passarem**, **sem alterar os testes**.
- Instruir: implementar em TDD; seguir padrões do app (Composition API, `useI18n`, tipos em `types/`, componentes `@acme/ui`, Tailwind com tokens).

## Regras rápidas

| Regra | Valor |
|-------|--------|
| Textos visíveis | Sempre i18n (pt-BR); nunca hardcoded |
| Estilos | Tailwind; tokens do preset; sem `<style scoped>` |
| Componentes | Reutilizar do `@acme/ui` quando existir equivalente |
| Testes | Não alterar testes existentes; testivos cria, devoso implementa até passar |
| Naming | PascalCase componentes; props/emits camelCase; i18n snake_case |

## Referências

- Skills: `figma-design-system`, `figma-objetivos-criterios`, `testing`, `vue-components`, `folder-structure`, `ui-library`
- Exemplo de spec de layout no repo: `apps/web/src/components/orders/OrderList/LAYOUT_SPEC.md`
