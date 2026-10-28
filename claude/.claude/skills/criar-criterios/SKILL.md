---
name: criar-criterios
description: Busca tela no Figma via MCP e produz objetivos e critérios de aceite por funcionalidade. Usar com link do Figma e lista de funcionalidades; integra com /criar-spec e /criar-criterios quando a spec precisar desse nível de detalhe visual.
---

# Objetivos e Critérios de Aceite a partir do Figma

Gera **objetivo** (ao menos 1) e **critérios de aceite** (máximo 10) por funcionalidade, usando o design do Figma como referência.

## Fluxo

1. **Extrair do link do Figma**
   - URL: `https://www.figma.com/design/:fileKey/:fileName?node-id=XXXX-YYYY`
   - `fileKey`: valor de `:fileKey` (ex.: `AbC123xYz456DeF789gHi0`)
   - `nodeId`: `node-id` com hífen trocado por dois-pontos (ex.: `4415-33144` → `4415:33144`)

2. **Buscar o design no Figma (MCP)**
   - Chamar `get_design_context` (server `plugin-figma-figma`) com `fileKey`, `nodeId`, e opcionalmente `clientLanguages: "typescript"`, `clientFrameworks: "vue"`.
   - Chamar `get_screenshot` com os mesmos parâmetros para obter descrição visual da tela.
   - Se a resposta for "section node" / metadados esparsos, usar o retorno de `get_screenshot` (e, se existir, `get_metadata`) como contexto para as funcionalidades.

3. **Produzir requisitos**
   - Se o usuário mencionar **requison** ou pedir análise de requisitos, delegar ao subagent **requison** com:
     - Contexto do design (resumo do que aparece na tela/estados).
     - Lista das funcionalidades informadas pelo usuário.
     - Regras: pelo menos 1 objetivo por funcionalidade; no máximo 5 critérios por funcionalidade; texto em português; critérios testáveis.
   - Caso contrário, produzir no mesmo formato você mesmo, com base no contexto do Figma e na lista de funcionalidades.

4. **Formato da entrega**
   - Para cada funcionalidade: **título** → **Objetivo** (uma frase) → **Critérios de aceite** (até 5, numerados).
   - Preferir critérios no formato Dado/Quando/Então quando fizer sentido.
   - Sem introduções longas; direto ao ponto.

5. **Levantamento dos criterios**
   - Para levantar os creterios seja bem criterioso em relação valores presentes na tela, por exemplo em tabelas analisa bem as colunas e deixe bem claro quais as colunas presente;
   - Em caso de enuns como status, deixe claro TODOS os status presentes na tela;
   - Descreva por exemplo corretamente qual é a ordem das coisas, por exemplo em uma linha de uma tabela se existe um botão ao lado de um texto, descreva isso bem "Ao lado do nome do usuario existe um botão de tres pontos para abrir um menu";

## Regras

| Regra | Valor |
|-------|--------|
| Objetivos por funcionalidade | ≥ 1 |
| Critérios de aceite por funcionalidade | ≤ 5 |
| Idioma | Português |
| Estilo dos critérios | Testáveis; Dado/Quando/Então quando aplicável |

## Exemplo de prompt do usuário

```
/requison Eu quero que voce use o MCP do Figma para pegar essa tela aqui: [LINK DO FIGMA]
E levantar Objetivo e critérios de aceite
Quero pelo menos 1 objetivo para cada funcionalidade
e no minimo 5 criterios e no maximo 10 para cada funcionalidade
nesse link tem as seguintes funcionalidades

- Listagem de chaves com tela de quando não tem nenhuma cadastrada
- Botão de nova chave de API que abre o drawer para escolher o escopo da chave...
- Fluxo de criação de chave de API com estado de erro
...
```

## Exemplo de saída (trecho)

```markdown
## 1. Listagem de chaves com tela vazia

**Objetivo:** Permitir que o usuário visualize todas as chaves de API cadastradas e, quando não houver nenhuma, ver um estado vazio que incentive o cadastro.

**Critérios de aceite:**
1. Dado que existem chaves cadastradas, quando o usuário acessa a listagem, então é exibida uma tabela com colunas Tipo, Chave, Status e Ações.
2. Dado que não existem chaves cadastradas, quando o usuário acessa a listagem, então é exibido o estado vazio com mensagem e botão "Cadastrar nova chave".
...
```
