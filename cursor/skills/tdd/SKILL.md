---
name: tdd
description: Implementa uma funcionalidade a partir de Figma e critérios de aceite em etapas com artefatos obrigatórios — LAYOUT_SPEC.md (figoso), TESTS.md + testes (testivos), DEV.md + código (devoso), REFACTOR.md + refatoração (refoso), AVALIACAO.md (avaliason). Entre cada etapa, o fluxo para e só continua após aprovação explícita do usuário sobre os artefatos entregues. Use quando o usuário chamar /tdd ou pedir para implementar uma tela a partir do Figma com testes primeiro.
---

# Figma + critérios de aceite + TDD

Implementa uma **funcionalidade** (tela ou bloco de UI) com **pipeline fixo de artefatos**: cada agente entrega um documento (ou documento + código) **nesta ordem**, sem pular etapas. Vale tanto invocado por esta skill quanto em chamada direta a qualquer um dos agentes (`figoso`, `testivos`, `devoso`, `refoso`, `avaliason`).

Cada etapa é um agente chamado pela ferramenta `Task` com o `subagent_type` correspondente. A sessão principal orquestra, apresenta os artefatos e pede aprovação; o trabalho da etapa é do agente.

## Princípio inviolável: o artefato guia a tarefa

- O arquivo de planejamento da etapa (`TESTS.md`, `DEV.md`, `REFACTOR.md`) é o **contrato** do que vai ser feito em seguida. A implementação materializa esse contrato; nunca o inverso.
- **Ordem rígida por etapa:** 1) gravar o `.md` completo na pasta da feature; 2) só então criar ou editar arquivos de teste, produção ou refatoração.
- **Proibido** na mesma corrida do agente: alterar código de produto, testes ou refatorar antes de o artefato correspondente existir gravado. Exceção: leitura e análise para escrever o plano.
- Se o plano ficar desatualizado durante a execução: atualizar o `.md` primeiro, depois o código.
- `AVALIACAO.md` só conta como entregue quando estiver no disco com todos os pontos; resumo no chat não substitui.

**Regra de ouro, aprovação humana:** ao final de cada etapa, a sessão entrega os artefatos (resumo + caminhos), **para** e não invoca o próximo agente até o usuário aprovar explicitamente ("pode continuar", "aprovado") ou pedir ajustes. Ajustes são feitos dentro da mesma etapa, e só depois se pede aprovação de novo.

## Artefatos por etapa

| Etapa | Agente | Artefato | Ordem de trabalho |
|-------|--------|----------|-------------------|
| 1 | **figoso** | `LAYOUT_SPEC.md` | Único entregável: layout + estrutura de componentes. → Gate |
| 2a | **testivos** | `TESTS.md` (árvore) | Só o plano, no formato árvore abaixo. Nenhum `.spec`/`.test` nesta invocação. → Gate |
| 2b | **testivos** | arquivos de teste | Nova invocação: traduz a árvore para Vitest/RSpec. A suíte fica **vermelha**: sem código de produto nem atalho para verde. → Gate |
| 3 | **devoso** | `DEV.md` → código | Grava `DEV.md` com base nos testes, depois implementa até ficarem verdes, sem alterar testes. → Gate |
| 4 | **refoso** | `REFACTOR.md` → refatoração | Com a suíte verde, grava `REFACTOR.md` (regras do projeto, código morto, defesas redundantes, front × API), depois aplica. Sem nada a fazer: "N/A" com o motivo. → Gate |
| 5 | **avaliason** | `AVALIACAO.md` | Analisa o diff e grava todos os pontos (severidade, arquivo, sugestão) para o devoso corrigir. → Gate antes de nova rodada do devoso |

**Onde salvar:** na pasta da feature (mesmo diretório do `LAYOUT_SPEC.md` ou pasta acordada). Nomes fixos: `LAYOUT_SPEC.md`, `TESTS.md`, `DEV.md`, `REFACTOR.md`, `AVALIACAO.md`.

## Formato de `TESTS.md` (etapa 2a)

Sempre uma árvore legível: cabeçalhos `### A.`, `### B.`… com o nome do alvo entre backticks; em cada um, bloco `text` com linhas `describe` / `context` / `it` indentadas. É o modelo mental comum a JS e RSpec; ainda não é o arquivo de teste.

```text
describe('OrderItemModal')
  describe('when closed (open=false)')
    it('does not render modal content in the document')
```

Regras completas no agente **testivos**. Na etapa 2b o testivos converte cada nó para o framework do repo, sem renomear nem pular cenário.

## Input necessário

- Link do Figma do nó ou tela.
- Objetivo (opcional, uma frase).
- Critérios de aceite (recomendado até 5), testáveis.
- Pasta da feature.

Se faltar algo essencial, pergunte antes de avançar.

## Fluxo por etapas

### 1. figoso → `LAYOUT_SPEC.md`

- Input: link do Figma + pasta da feature.
- Saída: `LAYOUT_SPEC.md` (MCP `get_design_context` / `get_screenshot`, tokens, estrutura de componentes). Sem inventar assets.
- Parar e pedir aprovação para a etapa 2.

### 2. testivos, em dois passos

- **2a:** invocar testivos com instrução explícita de **Fase A apenas**: gravar `TESTS.md` em árvore e parar. Contexto: objetivo, critérios de aceite, `LAYOUT_SPEC.md`. Parar e pedir aprovação do `TESTS.md` (conteúdo e cobertura).
- **2b:** só após aprovação, invocar testivos de novo com **Fase B**: criar os arquivos reais conforme o `TESTS.md`. Testes novos podem falhar até o devoso. Testes já existentes no projeto ficam intactos.
- Parar e pedir aprovação para a etapa 3.

### 3. devoso → `DEV.md` antes do código

- Contexto: critérios, `LAYOUT_SPEC.md`, `TESTS.md`, caminhos dos testes criados.
- Fluxo do devoso: ler testes e `TESTS.md`; gravar `DEV.md` (arquivos a criar ou alterar, métodos principais, ordem); só então implementar até todos os testes passarem.
- Parar e pedir aprovação para a etapa 4.

### 4. refoso → `REFACTOR.md` antes de tocar no código

- Contexto: código atual, `DEV.md`, testes verdes, regras do projeto (`CLAUDE.md`, `.cursor/rules`).
- Fluxo do refoso: gravar `REFACTOR.md` (ou N/A explícito); só então refatorar, rodar os testes, comportamento externo igual.
- Parar e pedir aprovação para a etapa 5.

### 5. avaliason → `AVALIACAO.md`

- Fluxo do avaliason: revisar o diff; gravar `AVALIACAO.md` com todos os pontos num documento único para o devoso consumir.
- Parar e pedir aprovação antes de qualquer nova invocação do devoso.
- O devoso lê `AVALIACAO.md` e aplica as correções sem alterar testes; nova revisão do avaliason conforme combinado com o usuário.

## Regras rápidas

| Tema | Regra |
|------|-------|
| Testes existentes | Intocáveis; testivos cria novos; devoso e refoso não tocam em testes |
| Textos visíveis | Seguem o mecanismo de i18n do projeto quando ele existir |
| Componentes e estilos | Reutilizar a biblioteca e os tokens do projeto antes de criar |
| Migrations | Só com pedido explícito do usuário |
| Git | Sem commit, push ou branch nova dentro do fluxo |

## Anti-padrões

- "Implementei X e segue o `DEV.md`" com o `DEV.md` escrito depois: inválido.
- 2a e 2b na mesma invocação do testivos.
- Substituir o trabalho do agente "na mão" com esta skill ativa. Se a invocação falhar, tentar de novo.
