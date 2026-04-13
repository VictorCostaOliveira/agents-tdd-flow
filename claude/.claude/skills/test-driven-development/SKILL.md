---
name: test-driven-development
description: Implementa funcionalidade a partir de Figma e critérios de aceite em etapas com artefatos obrigatórios — LAYOUT_SPEC.md (figoso), TESTS.md + testes (testivos), DEV.md + código (devoso), REFACTOR.md + refatoração (refoso), AVALIACAO.md (avaliason). Entre cada etapa, o fluxo para e só continua após aprovação explícita do usuário sobre os artefatos entregues.
---

# Figma + Critérios de Aceite + TDD

Implementa uma **funcionalidade** (tela ou bloco de UI) com **pipeline fixo de artefatos**: cada agente **sempre** entrega um documento (ou documento + código) **nesta ordem**, sem pular etapas. Isso vale **sempre** — invocado por esta skill **ou** chamada direta a qualquer um dos agentes (`figoso`, `testivos`, `devoso`, `refoso`, `avaliason`).

## Princípio inviolável: o artefato **guia** a tarefa (não o contrário)

- O arquivo de planejamento da etapa (**`TESTS.md`**, **`DEV.md`**, **`REFACTOR.md`**) é o **contrato** do que vai ser feito em seguida. A implementação **materializa** esse contrato — **não** o inverso (não “fazer código e depois descrever o que foi feito”).
- **Ordem rígida por etapa:** **1)** persistir o `.md` no disco na pasta da feature (conteúdo completo para aquela fase); **2)** só então criar/editar arquivos de teste, produção ou refatoração conforme a etapa.
- **Proibido** na mesma corrida do agente: alterar código de produto, testes ou refatorar **antes** de existir o artefato correspondente **gravado**. Exceção: leitura de arquivos e análise para **escrever** o plano.
- **Testivos:** gravar `TESTS.md` (**formato árvore**: `### A.`… + bloco `text` / describe·context·it; ver agente **testivos**) e **não** criar `.spec`/`.test` na mesma invocação até o usuário aprovar o plano (ver etapa 2).
- Se, durante a execução, o plano ficar desatualizado: **atualizar o `.md` primeiro**, depois o código.
- **`AVALIACAO.md` (avaliason):** o raciocínio pode ser interno, mas a revisão **só conta como entregue** quando **`AVALIACAO.md`** estiver no disco com todos os pontos — não substituir por um resumo longo só no chat.

**Regra de ouro — aprovação humana:** ao final de **cada etapa**, o assistente **entrega** os artefatos (resumo + caminhos dos arquivos), **para** e **não invoca o próximo agente** nem avança o trabalho até o usuário **aprovar explicitamente** (ex.: "pode continuar", "aprovado", "seguinte etapa") ou pedir ajustes. Se houver ajustes, **corrigir dentro da mesma etapa** e só depois voltar a pedir aprovação.

## Artefatos por etapa (obrigatórios)

| Etapa | Agente | Artefato(s) | Ordem de trabalho |
|-------|--------|---------------|---------------------|
| 1 | **figoso** | **`LAYOUT_SPEC.md`** | Único entregável desta etapa (layout + estrutura de componentes). → **Gate: aprovação** |
| 2 | **testivos** | **`TESTS.md`** (árvore obrigatória) → (gate) → **arquivos de teste** | **Subpasso 2a:** só **testivos** — gravar **`TESTS.md`** no formato **árvore** (`### A.`… + bloco `text` com `describe`/`context`/`it`; ver agente **testivos**) e **parar**; **não** criar `.spec`/`.test` na mesma invocação. **Subpasso 2b:** após **aprovação**, **nova** chamada a **testivos** — traduzir o plano para Vitest/RSpec/etc.; **suíte pode falhar** (sem código de produto nem mínimo para verde). → **Gate: aprovação** entre 2a e 2b |
| 3 | **devoso** | **`DEV.md`** → depois **código** | **Primeiro** escrever `DEV.md` com planejamento (arquivos, métodos, ordem) **com base nos testes** existentes. **Depois** implementar até todos passarem, **sem alterar testes**. → **Gate: aprovação** |
| 4 | **refoso** | **`REFACTOR.md`** → depois **refatoração no código** | Com testes **verdes**, **primeiro** escrever `REFACTOR.md` (alinhamento a **rules do projeto**, remoção de mortos/defesas excessivas, simplificação, **front vs API** quando couber — **sem mudar comportamento**). **Depois** aplicar refatoração; testes **devem continuar a passar**; **não alterar testes**. Se não houver nada a refatorar, `REFACTOR.md` com uma linha *"N/A — nada a refatorar neste momento"* e seguir para o gate. → **Gate: aprovação** |
| 5 | **avaliason** | **`AVALIACAO.md`** | **Primeiro** analisar o diff/código. **Depois** persistir **todos** os pontos levantados em `AVALIACAO.md` para o **devoso** ler e corrigir. → **Gate: aprovação** antes de nova ronda do devoso |

**Onde salvar:** na **pasta da feature** (mesmo diretório do `LAYOUT_SPEC.md` ou pasta acordada no contexto). Nomes fixos: `LAYOUT_SPEC.md`, `TESTS.md`, `DEV.md`, `REFACTOR.md`, `AVALIACAO.md`.

## Formato de `TESTS.md` (Fase A do testivos)

O plano de testes é **sempre** uma **árvore legível**: cabeçalhos `### A.`, `### B.`… com o nome do suíte entre backticks; em cada bloco, código-fenced com linguagem `text` e linhas `describe` / `context` / `it` indentadas (modelo mental comum a JS e RSpec — ainda não é o arquivo de teste). **Exemplo:**

```text
describe('OrderItemModal')
  describe('when closed (open=false)')
    it('does not render modal content in the document / UiModal receives open=false')
```

Detalhes e regras completas: **`~/.cursor/agents/testivos.md`**. Na **Fase B**, o testivos **converte** a árvore para arquivos de teste reais; a suíte deve poder **falhar** (vermelho) — **sem** implementar a feature nem atalhos para verde; isso fica para **devoso** (etapa 3).

## Input necessário

- **Link do Figma** do nó/tela
- **Objetivo** (opcional, uma frase)
- **Critérios de aceite** (recomendado máx. 5), testáveis

## Fluxo por etapas (detalhado)

### 1. Figoso → `LAYOUT_SPEC.md`

- Invocar **figoso** (`.cursor/agents/figoso.md`).
- Input: link do Figma + pasta da feature.
- Saída obrigatória: **`LAYOUT_SPEC.md`** (MCP `get_design_context` / `get_screenshot`, tokens, estrutura de componentes).
- Não inventar assets; preferir download via MCP quando existir.
- **Parar.** Mostrar o que foi entregue e pedir **aprovação** para a etapa 2.

### 2. Testivos — **dois passos** (gate entre plano e código de teste)

**Problema a evitar:** implementar arquivos `.spec`/`.test` na **mesma** invocação em que se grava `TESTS.md`, antes do usuário aprovar o plano.

- **2a — Só plano:** Invocar **testivos** (`subagent_type: "testivos"`) com instrução explícita: **Fase A apenas** — persistir **`TESTS.md`** no **formato de árvore obrigatório** (ver secção *Formato de `TESTS.md`* acima e agente **testivos**), **não** criar/editar arquivos de teste. Contexto: objetivo, critérios de aceite, `LAYOUT_SPEC.md`.
- **Parar.** Entregar resumo + paths. Pedir **aprovação** do **`TESTS.md`** (conteúdo e cobertura de cenários).
- **2b — Código de teste:** Só após o usuário aprovar, invocar **testivos** **de novo** com **Fase B** — criar/editar os arquivos reais (Vitest, RSpec, etc.) conforme `TESTS.md`. **Não** implementar produção nem stub mínimo para ficar verde: testes novos podem **falhar** até o **devoso** (etapa 3). Ver agente **testivos** (*Phase B = red*).
- **Não** alterar testes **já existentes** do projeto; apenas adicionar novos.
- Entrega completa da etapa 2: **`TESTS.md`** (aprovado) + **arquivos de teste** novos (vermelho esperado ao rodar).
- **Parar.** Pedir **aprovação** para a etapa 3 (devoso).

### 3. Devoso → `DEV.md` **antes** da implementação

- Invocar **devoso** (`subagent_type: "devoso"`).
- Contexto: critérios, `LAYOUT_SPEC.md`, **`TESTS.md`**, paths dos arquivos de teste criados.
- **Fluxo obrigatório do devoso:**
  1. **Ler** testes e `TESTS.md`.
  2. **Escrever `DEV.md`**: arquivos a criar/alterar, métodos/funções principais, ordem sugerida (alinhada aos testes).
  3. **Só então** implementar código até **todos** os testes passarem, **sem alterar testes**.
- Entrega da etapa: **`DEV.md`** + código (testes verdes).
- **Parar.** Pedir **aprovação** para a etapa de refatoração (4).

### 4. Refoso → `REFACTOR.md` **antes** de tocar no código

- Invocar **refoso** (`subagent_type: "refoso"`).
- Contexto: código atual, `DEV.md`, testes verdes, paths para **`.cursor/rules`** e convenções do repo.
- **Fluxo obrigatório do refoso:**
  1. **Escrever `REFACTOR.md`**: conformidade com rules, remoções, simplificação de defesas, nomes, **e** notas *front vs API* (filtros/ordenação/etc.) quando aplicável — ou *N/A* explícito.
  2. **Só então** aplicar refatorações; **rodar testes**; comportamento externo igual; **não alterar testes**.
- Entrega: **`REFACTOR.md`** + código refatorado (testes ainda verdes).
- **Parar.** Pedir **aprovação** para a etapa 5 (avaliason).

### 5. Avaliason → `AVALIACAO.md`

- Invocar **avaliason** após a refatoração aprovada.
- **Fluxo obrigatório do avaliason:**
  1. Revisar mudanças (git diff / escopo combinado).
  2. **Escrever `AVALIACAO.md`** com **todos** os pontos (severidade, arquivo, sugestão), no mesmo espírito do formato de review do agente — documento único para o **devoso** consumir.
- **Parar.** Pedir **aprovação** antes de qualquer nova invocação do **devoso** para correções.
- O **devoso** (nova invocação se necessário) lê **`AVALIACAO.md`** e aplica correções **sem alterar testes**, até fechar os itens acordados; após um ciclo de correções, pode voltar a pedir-se revisão do avaliason conforme combinado com o usuário.

### IMPORTANTE

- **Todos** os subagentes **devem** ser chamados em sequência **respeitando os gates de aprovação**. Não avançar etapa sem confirmação do usuário. Se a invocação falhar, **tentar de novo**. Não substituir o trabalho do agente “na mão” quando esta skill estiver ativa.
- **Nunca** pular: `TESTS.md` **gravado** antes de qualquer `.spec`/`.test`; `DEV.md` **gravado** antes de código de produção; **`REFACTOR.md` gravado** antes de editar para refatorar (ou N/A documentado no próprio `REFACTOR.md`); **`AVALIACAO.md` gravado** antes de dar a revisão como concluída.
- **Anti-padrão explícito:** “Implementei X e segue o `DEV.md`” quando o `DEV.md` foi escrito **depois** — **inválido** neste fluxo.
- **Figoso** → somente `LAYOUT_SPEC.md` como artefato de spec de layout.
- **Testivos** e **devoso** seguem **doc primeiro → código**; **refoso** idem com **`REFACTOR.md`**.
- **TDD:** vermelho → verde → **refatorar** (etapa 4 com **refoso**); repetir apenas dentro das regras acima.

## Regras rápidas

| Regra | Valor |
|-------|--------|
| Textos visíveis | Sempre i18n (pt-BR); nunca hardcoded |
| Estilos | Tailwind; tokens do preset; sem `<style scoped>` |
| Componentes | Reutilizar `@acme/ui` quando existir equivalente |
| Testes | Não alterar testes existentes; testivos cria novos; devoso e refoso **não** tocam em testes |
| Naming | PascalCase componentes; props/emits camelCase; i18n snake_case |

## Referências

- **Skills por etapa (sem subagentes Task):** `test-driven-development-skills` — `~/.cursor/skills/test-driven-development-skills/SKILL.md`; comando **`/tdd-skills`**.
- Agentes: **figoso**, **testivos**, **devoso**, **refoso**, **avaliason** (`.cursor/agents/*.md` no projeto ou `~/.cursor/agents/`) — fluxo **doc primeiro → execução** onde aplicável.
- Skills: `figma-design-system`, `figma-objetivos-criterios`, `testing`, `vue-components`, `folder-structure`, `ui-library`
- Exemplo de layout: `apps/web/src/components/orders/OrderList/LAYOUT_SPEC.md`
