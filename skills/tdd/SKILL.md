---
name: tdd
description: Implementa uma funcionalidade a partir de um link do Figma e critérios de aceite: levanta specs visuais via Figma MCP, depois cria testes (testivos) e implementa em TDD (devoso). Use quando o usuário tiver um link do Figma, objetivo/critérios de aceite e quiser testes primeiro e implementação em seguida.
---

# Figma + Critérios de Aceite + TDD

Implementa uma **funcionalidade** (qualquer tela ou bloco de UI) a partir de um design no Figma: levanta especificações visuais via MCP, cria testes com base nos critérios de aceite e implementa até os testes passarem.

## Input necessário

- **Link do Figma** da tela ou do nó (ex.: `https://www.figma.com/design/AbC123xYz456DeF789gHi0/...?node-id=1234-5678`)
- **Objetivo** (opcional, uma frase): o que a funcionalidade deve permitir ao usuário
- **Critérios de aceite** (recomendado máx. 5): testáveis; servem de base para os testes e para a implementação

## Fluxo em 4 etapas

### 1. Levantar specs do Figma e definir estrutura de componentes (figoso)

- Invocar o **agente figoso** (ver `.cursor/agents/figoso.md`): ele é especialista em analisar Figma via MCP e produzir LAYOUT_SPEC.md + estrutura de componentes.
- Entregar como input: **link do Figma** (e, se houver, pasta/contexto da feature onde o spec deve ser salvo).
- O figoso:
  - Extrai da URL `fileKey` e `nodeId`; chama Figma MCP (`get_design_context`, `get_screenshot`) com `clientLanguages: "typescript"`, `clientFrameworks: "vue"`.
  - Produz **LAYOUT_SPEC.md** na pasta da feature (cores → tokens Tailwind, tipografia, espaçamentos, componentes visuais; ver skill `figma-design-system`).
  - Define **estrutura de componentes**: página/rota, componentes novos, pastas (seguindo `folder-structure` e `vue-components`), responsabilidade de cada um.
- Resultado desta etapa: **LAYOUT_SPEC.md** + documentação da estrutura de componentes (no próprio spec ou em bloco dedicado). Usar esse resultado como contexto nas etapas 2 e 3.
- Não invente assets, tente baixar os assets presentes na tela com o MCP do figma para usar os assets de corretos.

### 2. Criar testes (testivos)

- Chamar o **subagente testivos** (`mcp_task` com `subagent_type: "testivos"`).
- Entregar como contexto:
  - **Objetivo** e **critérios de aceite** (input do usuário).
  - Resultado do **passo 1 (figoso)**: onde a feature fica (página, rotas), **quais componentes** foram definidos e o **LAYOUT_SPEC.md** (ou resumo) para alinhar expectativas visuais.
- Instruir: criar testes (Vitest + @vue/test-utils) que validem os critérios de aceite; seguir convenções do projeto (describe/context/it, helpers de mount do app).
- **Não** alterar testes existentes; apenas criar novos.

### 3. Implementar conforme testes (devoso)

- Chamar o **subagente devoso** (`mcp_task` com `subagent_type: "devoso"`).
- Entregar como contexto:
  - Objetivo e critérios de aceite.
  - Resultado do **passo 1 (figoso)**: estrutura de componentes e LAYOUT_SPEC.md.
  - Que os **testes já foram criados** pelo testivos e que a implementação deve fazer **todos os testes passarem**, **sem alterar os testes**.
- Instruir: implementar em TDD; seguir padrões do app (Composition API, `useI18n`, tipos em `types/`, componentes `@acme/ui`, Tailwind com tokens).

### 4. Após implementação (avaliason)

- Chamar o **subagente avaliason** para analisar as changes feitas e levantar melhorias e devolver para o devoso para ele implementar as changes.

### IMPORTANTE
- todos os subagentes DEVEM ser chamados. Se algum agente tiver problema para ser invocado, voce deve tentar novamente. Nao quero que voce execute as tarefas sem ser com o agente quando essa skill for invocada.
- **Passo 1:** chamar o figoso com o link do Figma para obter LAYOUT_SPEC.md e estrutura de componentes.
- **Passo 2:** chamar o subagente testivos para gerar os testes (com base em objetivo, critérios de aceite e resultado do figoso).
- **Passo 3:** chamar o devoso para implementar em TDD: fazer um teste passar (sem alterar o teste), depois o próximo cenário, e assim sucessivamente.
- **Passo 4:** após terminar a implementação, chamar o avaliason para avaliar o código e o devoso para corrigir os TODOS pontos levantados.
- Seguir o flow do TDD: teste → faz o teste passar → avalia e refatora → próximo cenário.

## Regras rápidas

| Regra | Valor |
|-------|--------|
| Textos visíveis | Sempre i18n (pt-BR); nunca hardcoded |
| Estilos | Tailwind; tokens do preset; sem `<style scoped>` |
| Componentes | Reutilizar do `@acme/ui` quando existir equivalente |
| Testes | Não alterar testes existentes; testivos cria, devoso implementa até passar |
| Naming | PascalCase componentes; props/emits camelCase; i18n snake_case |

## Referências

- Agente: **figoso** (levantar specs do Figma e estrutura de componentes via MCP).
- Skills: `figma-design-system`, `figma-objetivos-criterios`, `testing`, `vue-components`, `folder-structure`, `ui-library`
- Exemplo de spec de layout no repo: `apps/web/src/components/orders/OrderList/LAYOUT_SPEC.md`