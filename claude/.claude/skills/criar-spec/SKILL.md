---
name: criar-spec
description: Cria a especificação antes do código. A Fase 1 (especificar) é sempre delegada ao agente requison, que elicita os requisitos e redige o núcleo da spec no template desta skill. Use ao começar um projeto, uma feature ou uma mudança grande sem spec. Com Figma, roda o fluxo MCP antes de fechar a spec. Use quando o usuário chamar /criar-spec ou pedir uma spec.
---

# Criar spec (desenvolvimento guiado por especificação)

## Visão geral

Escreva uma especificação estruturada antes de qualquer código. A spec é a fonte de verdade compartilhada entre você e o engenheiro: define o que estamos construindo, por quê, e como saberemos que está pronto. Código sem spec é chute.

### Rails + Vue

Quando o produto é uma API Rails com uma SPA Vue, a spec nomeia explicitamente as responsabilidades do servidor (Ruby) e do cliente (Vue), os jobs em background e os contratos de API.

## Quando usar

- Projeto ou feature nova
- Requisitos ambíguos ou incompletos
- Mudança que toca vários arquivos ou módulos
- Decisão de arquitetura à frente
- Tarefa que levaria mais de 30 minutos para implementar
- O usuário compartilhou um link do **Figma** ou a feature precisa bater com uma tela desenhada: rode o fluxo Figma na Fase 1 antes de fechar a spec

**Quando dispensar:** correção de uma linha, typo, ou mudança com requisito claro e autocontido.

## Fluxo com gates

Quatro fases. Só avance quando a fase atual estiver validada.

```
ESPECIFICAR ──→ PLANEJAR ──→ TAREFAS ──→ IMPLEMENTAR
     │             │            │             │
     ▼             ▼            ▼             ▼
  revisão       revisão      revisão       revisão
  humana        humana       humana        humana
```

### Fase 1: especificar

Esta skill define **o que** uma boa spec contém e **como** a Fase 1 é gated; o **trabalho da Fase 1 é sempre do agente `requison`**. O mesmo padrão de delegação de **`criar-criterios`** → requison e do **`/tdd`** → figoso/testivos: a sessão principal orquestra e consolida; o requison elicita e redige o núcleo.

#### Obrigatório: delegar a Fase 1 ao requison

1. **Invoque** o agente `requison` (Task com `subagent_type: "requison"`). Escrever a spec sozinho "para ir mais rápido" viola esta skill.
2. **Handoff** completo: nome do produto ou feature, visão ou objetivos, restrições, **URL do Figma + node** quando houver (ou "sem design" explícito), lista de funcionalidades ou telas, stack (ex.: Rails + Vue), idioma, decisões que o humano já tomou.
3. Instrua o requison a seguir **esta skill** (template, seis áreas, ASSUMPTIONS, seção Figma) e o próprio `agents/requison.md`.
4. Se a invocação falhar, tente de novo antes de qualquer atalho.
5. **Depois** que o requison devolver: **você** consolida em `SPEC.md`, completa com os fatos do repositório que esta skill exige (comandos reais do `package.json`, `Makefile` ou `bin/`, layout de pastas, trecho de estilo) e pede a revisão humana para fechar a Fase 1.

O requison é dono das perguntas estratégicas, do bloco **ASSUMPTIONS**, dos requisitos funcionais e não-funcionais, dos critérios de sucesso testáveis, dos critérios por funcionalidade quando houver lista, dos casos de borda e das **Open Questions**.

#### Quando há Figma

Com URL do Figma, frame nomeado ou trabalho guiado por design, o requison roda este fluxo **antes** de fechar o conteúdo, alinhado a **`criar-criterios`**:

1. **Parse do link**
   - Padrão: `https://www.figma.com/design/:fileKey/:fileName?node-id=XXXX-YYYY` (com `branch/`, use a chave da branch como `fileKey`).
   - `fileKey`: segmento após `/design/`.
   - `nodeId`: `node-id` com hífen trocado por dois-pontos (`4415-33144` → `4415:33144`).
   - FigJam e outros formatos: use a tool do MCP do Figma própria para aquele tipo (ex.: `get_figjam`).

2. **Buscar contexto via MCP do Figma**
   - `get_design_context` com `fileKey`, `nodeId` e, opcionalmente, `clientLanguages` / `clientFrameworks` alinhados ao projeto (`typescript`, `vue`).
   - `get_screenshot` com os mesmos parâmetros, como âncora visual.
   - Resposta rasa (section node, estrutura esparsa): apoie-se mais em `get_screenshot` e, se preciso, `get_metadata` para delimitar a árvore.

3. **Transformar design em insumo de spec** (responsabilidade do requison)
   - Liste **telas, estados e fluxos** visíveis ou implícitos (vazio, carregando, erro, sucesso).
   - Capture **copy**, **rótulos**, **colunas de tabela** e **valores de status** com precisão (mesmo rigor de `criar-criterios`: enums, ordem dos elementos, ações ao lado do conteúdo).
   - Anote **restrições** que o design implica (campos obrigatórios, tamanhos máximos anotados, breakpoints).
   - **Comportamento não resolvido** (o que acontece no submit, erros de API) vai para **Open Questions**, sem chute.

4. **Fundir no template** (saída esperada do requison)
   - **Objective** e **Success Criteria** refletem o que o design mostra *e* o que o produto precisa alcançar.
   - Subseção **Design reference**: link, `fileKey`, `nodeId`, data da consulta, para quem implementa reabrir o mesmo nó.
   - Se o usuário pediu **objetivos e critérios por funcionalidade**, produza esse bloco no estilo de `criar-criterios` dentro da spec e mantenha as demais áreas.

5. **Suposições continuam explícitas**
   - O design mostra *como* a UI é, e raramente regras de backend ou permissões. Depois do Figma, liste **ASSUMPTIONS** sobre dados, auth e bordas, e peça confirmação.

**O Figma nunca é pulado** quando o usuário colou o link ou pediu "spec a partir desta tela", salvo link quebrado e humano de acordo em seguir sem design.

**Suposições vêm primeiro.** Antes de consolidar, o requison lista o que está assumindo:

```
ASSUMPTIONS:
1. É uma aplicação web (não mobile nativo)
2. Autenticação por sessão com cookie (não JWT)
3. Banco PostgreSQL (pelos models ActiveRecord existentes)
4. Só navegadores modernos
→ Corrija agora ou sigo com estas.
```

Lacuna ambígua nunca é preenchida em silêncio. O propósito da spec é expor mal-entendidos *antes* do código, e suposição é a forma mais perigosa de mal-entendido.

**A saída do requison cobre estas seis áreas** (o orquestrador só completa o que depende de inspecionar o repo):

1. **Objective:** o que estamos construindo e por quê, para quem, o que é sucesso.
2. **Commands:** comandos completos com flags, e não só nomes de ferramenta.
   ```
   Test: bundle exec rspec
   Lint: bundle exec rubocop
   Front: pnpm vitest run
   Dev: bin/dev
   ```
3. **Project Structure:** onde vive o código, os testes, a documentação.
   ```
   app/services    → serviços de domínio
   app/components  → componentes Vue
   spec/           → RSpec
   src/__tests__/  → Vitest
   ```
4. **Code Style:** um trecho real de código do projeto vale mais que três parágrafos. Convenções de nome, formatação, exemplo de saída boa.
5. **Testing Strategy:** framework, onde ficam os testes, expectativa de cobertura, que nível de teste para qual preocupação.
6. **Boundaries:** três níveis:
   - **Sempre:** rodar testes antes de commit, seguir convenções de nome, validar entrada
   - **Perguntar antes:** mudança de schema, dependência nova, mudança de CI
   - **Nunca:** commitar segredo, editar `vendor/`, remover teste falhando sem aprovação

**Template:**

```markdown
# Spec: [Projeto/Feature]

## Objective
[O que e por quê. Histórias de usuário ou critérios de aceite.]

## Design reference (quando houver Figma)
[URL, fileKey, nodeId, data. Frames usados.]

## Tech Stack
[Framework, linguagem, dependências-chave com versão]

## Commands
[Build, test, lint, dev, completos]

## Project Structure
[Pastas com descrição]

## Code Style
[Trecho de exemplo + convenções]

## Testing Strategy
[Framework, local dos testes, cobertura, níveis]

## Boundaries
- Sempre: [...]
- Perguntar antes: [...]
- Nunca: [...]

## Success Criteria
[Condições específicas e testáveis]

## Open Questions
[O que ainda precisa de decisão humana]
```

**Reformule instruções como critérios de sucesso.** Requisito vago vira condição concreta:

```
REQUISITO: "Deixar o dashboard mais rápido"

CRITÉRIOS REFORMULADOS:
- LCP do dashboard < 2,5 s em conexão 4G
- Carga inicial de dados em < 500 ms
- Sem layout shift durante a carga (CLS < 0,1)
→ São estes os alvos?
```

### Fase 2: planejar

Com a spec validada, gere o plano técnico:

1. Componentes principais e dependências entre eles
2. Ordem de implementação (o que vem primeiro)
3. Riscos e mitigações
4. O que pode ser paralelo e o que é sequencial
5. Pontos de verificação entre fases

O plano é revisável: o humano lê e diz "é por aí" ou "muda X".

### Fase 3: tarefas

Quebre o plano em tarefas discretas:

- Cada tarefa cabe em uma sessão focada
- Cada tarefa tem critérios de aceite explícitos
- Cada tarefa tem um passo de verificação (teste, build, checagem manual)
- Ordem por dependência, e não por importância percebida
- Nenhuma tarefa toca mais de ~5 arquivos

```markdown
- [ ] Tarefa: [descrição]
  - Aceite: [o que precisa ser verdade ao terminar]
  - Verificar: [como confirmar: comando de teste, build, checagem manual]
  - Arquivos: [quais serão tocados]
```

### Fase 4: implementar

Execute uma tarefa por vez em TDD. Para tela a partir do Figma, use o `/tdd`. Carregue a seção da spec e os arquivos relevantes a cada passo, em vez de inundar o contexto com a spec inteira.

## Spec viva

- **Decisão mudou:** atualize a spec primeiro, depois implemente.
- **Escopo mudou:** feature adicionada ou cortada aparece na spec.
- **Spec versionada:** mora no repositório junto com o código.
- **PR referencia a spec:** link para a seção que cada PR implementa.

## Racionalizações comuns

| Racionalização | Realidade |
|---|---|
| "É simples, dispenso spec" | Tarefa simples dispensa spec *longa*; critérios de aceite continuam necessários. Duas linhas bastam. |
| "Escrevo a spec depois de codar" | Isso é documentação, e não especificação. O valor está em forçar clareza *antes*. |
| "A spec vai atrasar" | 15 minutos de spec evitam horas de retrabalho. |
| "Os requisitos vão mudar mesmo" | Por isso a spec é viva. Spec desatualizada ainda vale mais que nenhuma. |
| "O usuário sabe o que quer" | Até pedido claro carrega suposições implícitas. A spec as expõe. |

## Sinais de alerta

- Pular o `requison` na Fase 1 e escrever a spec inteira na sessão principal
- Começar a codar sem requisito escrito
- Perguntar "posso só começar a construir?" antes de definir o que é "pronto"
- Implementar algo que nenhuma spec ou tarefa cita
- Decidir arquitetura sem registrar
- Pular a spec porque "é óbvio"

## Verificação

Antes de implementar, confirme:

- [ ] Fase 1 executada pelo `requison` e consolidada em `SPEC.md`
- [ ] A spec cobre as seis áreas
- [ ] O humano revisou e aprovou
- [ ] Critérios de sucesso específicos e testáveis
- [ ] Boundaries (Sempre / Perguntar antes / Nunca) definidos
- [ ] Spec salva em arquivo no repositório
- [ ] Com Figma: design puxado via MCP (`get_design_context` + `get_screenshot`) e **Design reference** aponta para o `fileKey` / `nodeId` corretos
