---
name: tdd-tests-plan
description: "Etapa 2a do pipeline TDD por skills: grava TESTS.md só como árvore obrigatória (cabeçalhos A./B. com nome do suíte + bloco text describe/context/it) na pasta da feature e para até aprovação. Não cria nem edita .spec, .test ou RSpec na mesma invocação."
---

# TDD — Etapa 2a: `TESTS.md` apenas

**Sem subagentes:** não usar `Task` nem subagentes; executar esta etapa diretamente.

## Formato obrigatório de `TESTS.md`

O artefato é **sempre** uma **árvore legível**, não lista solta de bullets.

1. **Blocos de suíte:** cabeçalhos `### A.`, `### B.`, … com o **nome do alvo entre backticks** (componente Vue, composable, classe, request, etc.). Exemplo de linha de título: *### A. `OrderItemModal` (ou nome final equivalente)*.
2. **Árvore:** dentro de cada bloco, um único bloco com linguagem **`text`**, **indentação de 2 espaços** por nível, usando **`describe`**, **`context`** e **`it`** como rótulos (modelo comum a Vitest/Jest e a estilo RSpec — **ainda não é código**):

```text
describe('OrderItemModal')
  describe('when closed (open=false)')
    it('does not render modal content in the document / UiModal receives open=false')
```

3. **Cobertura:** todos os cenários que forem para a Fase 2b aparecem na árvore (edge cases, loading/erro/vazio quando couber).
4. **Idioma** das strings: alinhar aos testes já existentes no repo (muitas vezes inglês em `describe`/`it`).
5. **RSpec (Rails):** a mesma árvore mapeia para `describe` / `context` / `it` no estilo do projeto.

## Pré-requisitos

- `LAYOUT_SPEC.md` (e/ou critérios de aceite e objetivo).
- Pasta da feature.

## Obrigatório

1. Com base em **critérios de aceite**, **objetivo** e **`LAYOUT_SPEC.md`**, preencher **`TESTS.md` inteiro** neste formato de árvore — **todos** os cenários planejados.
2. Persistir um único **`TESTS.md`** na pasta da feature — **nada** fica “só na cabeça”.
3. **Parar** após gravar `TESTS.md`: resumo + paths + pedido de **aprovação** do plano.

## Proibido nesta invocação

- Criar, editar ou tocar em **`*.spec.*`**, **`*.test.*`**, `*_spec.rb` ou qualquer teste real em disco.
- Avançar para implementação de testes — isso é **`tdd-tests-implement`** (2b), **após** aprovação (nessa etapa os specs passam a existir em código e podem **falhar** até **`tdd-dev`**).

## Ordem no disco

`TESTS.md` **gravado primeiro**; código de teste **depois** (outra invocação / mensagem explícita de Fase B).

## Alinhamento

- Inspecionar padrões de teste do projeto (naming, pastas, Vitest/RSpec) para o **plano** refletir o que será codificado em 2b.
- **Nunca** alterar testes **já existentes** do projeto (salvo pedido explícito do utilizador).

## Fim da etapa

Gate: aprovação do **`TESTS.md`** antes de invocar mentalmente **`tdd-tests-implement`**.
