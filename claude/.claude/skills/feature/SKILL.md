---
name: feature
description: 'Comando único do PRD à feature pronta, com a sessão como manager: faz o grill do PRD até a SPEC, monta o plano em TDD com o modelo e o effort escolhidos para cada fase, delega cada fase ao devoso nesse modelo, avalia o que voltou antes de liberar a próxima e escala o modelo quando a entrega é reprovada. Para na aprovação da SPEC e na do plano. Use quando o usuário chamar /feature ou pedir o fluxo completo PRD → SPEC → plano → TDD com roteamento de modelos.'
---

# feature — do PRD à feature pronta, com a sessão como manager

A sessão principal é o manager: conversa com o usuário, decide o modelo de cada tarefa, delega e avalia. Os agentes executam: `devoso` implementa cada fase, `avaliason` e `security-auditor` auditam no fim. Rode numa sessão em **Opus**, porque o grill, o plano e a avaliação acontecem aqui.

## 1. Entradas

| Entrada | Se faltar |
|---|---|
| PRD (link ou arquivo) | pergunte; é a fonte do grill |
| Identificador da feature (card, issue) | pergunte; dá nome à pasta, à SPEC e à branch |
| Figma (links com `node-id`) | pergunte quando o PRD tem tela |

Pergunte tudo o que falta numa mensagem só. Tudo desta feature mora em `<pasta de specs>/<id>-<slug>/`.

**Retomada:** se a pasta já tem `PLANO-<id>.md`, leia o plano e siga da primeira fase com status diferente de `aprovada`.

## 2. SPEC com grill

1. Leia o PRD por inteiro e o código que ele toca. Delegue a leitura do código a agentes `Explore` com `model: haiku`, um por área, pedindo resposta em `caminho:linha`.
2. Grill: uma pergunta por vez, cada uma com a sua recomendação, até não restar decisão aberta. Fato que o repo responde, você levanta, sem perguntar.
3. Escreva `SPEC-<id>.md` na pasta da feature: objetivo, escopo e fora de escopo, requisitos numerados (§), contratos de API, dados, telas e estados, critérios de aceite, decisões tomadas.
4. **Gate 1:** o usuário aprova a SPEC. Publicar em outra ferramenta (wiki, Confluence) só com o ok dele.

## 3. Plano com roteamento

Escreva `PLANO-<id>.md` na pasta da feature, em plan mode quando houver:

1. **Cobertura da SPEC:** tabela `§ da SPEC → fase e cenário`. Todo requisito tem uma linha.
2. **Decisões por padrão:** onde a SPEC deixa aberto, a escolha que vale sem outra instrução.
3. **Ambiente e regras:** branch, comando de teste do repo, moldes de teste e de código com caminho.
4. **Roteamento:**

   | Fase | Modelo | Effort | Motivo | Tentativas | Status |
   |---|---|---|---|---|---|
   | 1. Endpoint X | sonnet | medium | segue o molde de `app/controllers/...` | 0 | pendente |

5. **Fases**, back primeiro, cada uma com a tabela `# | Cenário | Vermelho esperado | Verde`, em que o verde é o mínimo que resolve.
6. **Verificação ponta a ponta** e **pendências**.

**Gate 2:** o usuário aprova o plano e o roteamento juntos.

### Rubrica

Escolha pelo trabalho da fase, do nível mais barato que resolve:

| Modelo | Effort | Quando |
|---|---|---|
| `haiku` | `low` | trabalho mecânico sem decisão: leitura e busca, docs, coleção de API, ajuste de lint |
| `sonnet` | `medium` | fase de TDD que segue um molde que já existe no repo |
| `opus` | `high` | fase sem molde no repo, ou que toca dinheiro, autorização ou isolamento de tenant, concorrência ou idempotência, integração externa, migração de dados, contrato entre repos |
| `fable` | `high` | só por escalada depois de reprovação em `opus`, ou a pedido do usuário |

Na dúvida entre dois níveis, fique com o de cima.

Marque na coluna Motivo as fases de **risco**: as que foram para `opus` por tocar dinheiro, autorização ou tenant, concorrência, integração externa, migração de dados ou contrato entre repos. Fase em `opus` só por falta de molde não conta. Essa marcação define o tamanho da auditoria em §5.

### Cenário com dado real

Uma fase que lê histórico (tabela de versões, log de eventos, estado anterior de um registro) leva na tabela pelo menos um cenário que gera o histórico pelo fluxo real do domínio, chamando os métodos do model, com sequências que repetem estado ou valor (reprova → reenvia → reprova com o mesmo código, por exemplo). Registro de histórico montado à mão não substitui esse cenário, porque a ferramenta de auditoria costuma gravar só o que mudou.

## 4. Execução por fase

Antes da fase 1, prepare o ambiente você mesmo: a branch e o que o plano pede em "Ambiente e regras". Rode as fases uma de cada vez. Para cada fase:

1. Delegue ao `devoso` com o `model` e o `effort` do roteamento. O prompt leva: o caminho do plano e a seção da fase, a SPEC, os moldes, as restrições (sem commit, sem migration, testes da base intocados, só os specs da fase) e, na retentativa, o motivo da reprovação.
2. Avalie a entrega você mesmo, sem confiar no relatório:
   - rode os specs da fase;
   - leia os arquivos que a fase tocou contra a tabela de cenários e as linhas de cobertura;
   - confira que o vermelho relatado em cada cenário é o "vermelho esperado";
   - fase que lê histórico: confira que o cenário com dado real existe e passa pelo fluxo do model;
   - confira que nenhum teste da base foi alterado: `git diff <base> --diff-filter=MD --name-only -- <pasta de testes>` volta vazio.
3. Atualize o plano: tentativas, status (`aprovada` ou `reprovada: <motivo>`), desvios e respostas do usuário.

Reprovação:

- **1ª:** delegue de novo no mesmo modelo, com o feedback concreto.
- **2ª:** suba um nível (`haiku` → `sonnet` → `opus` → `fable`).
- **3ª:** pare e leve ao usuário, com a sua recomendação. Se `fable` não estiver disponível, o teto é `opus`.

## 5. Auditoria e fechamento

1. A auditoria acompanha o risco marcado no roteamento:
   - **nenhuma fase de risco:** um `avaliason` em `opus` (`high`), SPEC × plano × código, corrigindo em TDD o que está claro, e o `security-auditor` em `sonnet` (`medium`), só leitura, em paralelo;
   - **alguma fase de risco:** dois `avaliason` em `fable` (`high`), um de SPEC → código (corrige) e outro de código → SPEC (só reporta), e o `security-auditor` em `opus` (`high`).

   Nos dois casos, o prompt do auditor pede um cenário com dado real para cada leitura de histórico do diff.
2. Confira os achados lendo o código, aplique os reais e rode os specs e o lint.
3. Commit, PR e migration só com autorização explícita.
4. Mensagem final: o que cada fase entregou, o que a auditoria corrigiu, as pendências e a tabela de roteamento como terminou (modelo, tentativas, escaladas), que serve para calibrar a rubrica.
