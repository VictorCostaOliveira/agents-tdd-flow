---
name: feature
description: 'Comando único do PRD à feature pronta, com a sessão como manager: faz o grill do PRD até a SPEC, monta o plano em TDD com o modelo e o effort escolhidos para cada fase, delega cada fase ao devoso nesse modelo, avalia o que voltou antes de liberar a próxima e escala o modelo quando a entrega é reprovada. Para na aprovação da SPEC e na do plano. Use quando o usuário chamar /feature, colar um PRD (com ou sem card e Figma) pedindo para levar até a feature pronta, ou pedir o fluxo completo PRD → SPEC → plano → TDD com roteamento de modelos. A SPEC sai no padrão da spec-arquitetura e o plano exatamente como o da implementa-spec. Para só escrever a SPEC, use spec-arquitetura; para implementar uma SPEC já pronta sem roteamento, use implementa-spec.'
---

# feature — do PRD à feature pronta, com a sessão como manager

A sessão principal é o manager: conversa com o usuário, decide o modelo de cada tarefa, delega e avalia. Os agentes executam: `devoso` implementa cada fase, `avaliason` e `security-auditor` auditam no fim. Rode numa sessão em **Opus**, porque o grill, o plano e a avaliação acontecem aqui.

Esta skill orquestra o que já existe: a SPEC vem de `spec-arquitetura` (`.claude/skills/spec-arquitetura/SKILL.md`), e o plano, a auditoria e o fechamento vêm de `implementa-spec` (`.claude/skills/implementa-spec/SKILL.md`). Leia as seções citadas de lá quando chegar nelas.

## 1. Entradas

| Entrada | Se faltar |
|---|---|
| PRD (link ou arquivo) | pergunte; é a fonte do grill |
| Identificador da feature (card, issue) | pergunte; dá nome à pasta, à SPEC e à branch |
| Figma (links com `node-id`) | pergunte quando o PRD tem tela |
| SPEC mãe, se a feature for filha | use a que o PRD ou o card citam |

Pergunte tudo o que falta numa mensagem só. Tudo desta feature mora em `<pasta de specs>/<id>-<slug>/`.

**Retomada:** se a pasta já tem `PLANO-<id>.md`, leia o plano e siga da primeira fase com status diferente de `aprovada`. Se só tem a SPEC, siga do passo que falta.

## 2. SPEC com grill

1. Leia o PRD por inteiro e o código que ele toca. Delegue a leitura do código a agentes `Explore` com `model: haiku`, como em `implementa-spec` §2.
2. Grill: uma pergunta por vez, cada uma com a sua recomendação, até não restar decisão aberta. Fato que o repo responde, você levanta, sem perguntar.
3. Escreva a SPEC seguindo a skill `spec-arquitetura`: o "Como gerar" dela (contexto real do repo, `arquiteto` nos trade-offs, `N/A — <motivo>` no que não se aplica, premissas à vista) e o template com as 10 áreas. O que o grill decidiu vai para a área correspondente. Grave em `SPEC-<id>.md` na pasta da feature, em vez do `SPEC_ARQUITETURA.md` que a skill sugere.
4. **Gate 1:** o usuário aprova a SPEC local. Publicar em outra ferramenta (wiki) só com o ok dele. Daqui em diante, o plano e os auditores leem a versão publicada; sem publicação, a fonte é o `SPEC-<id>.md` local, e os prompts apontam para esse caminho.

## 3. Plano com roteamento

Leia `implementa-spec` §3 e monte o plano exatamente como ela pede, em plan mode: as dez seções, na mesma ordem, e cada fase com a tabela `# | Cenário | Vermelho esperado | Verde`, um cenário por vez, back primeiro. Toda área e todo requisito da SPEC têm linha em "Cobertura da SPEC". Grave uma cópia em `PLANO-<id>.md` na pasta da feature.

A única seção que esta skill acrescenta é **Roteamento**, logo depois de "Cobertura da SPEC"; nenhuma seção da §3 sai nem muda:

| Fase | Modelo | Effort | Motivo | Tentativas | Status |
|---|---|---|---|---|---|
| 1. Endpoint X | sonnet | medium | segue o molde de `app/controllers/...` | 0 | pendente |

O motivo é uma linha que aponte o critério da rubrica. **Gate 2:** o usuário aprova o plano e o roteamento juntos.

### Rubrica

Escolha pelo trabalho da fase, do nível mais barato que resolve:

| Modelo | Effort | Quando |
|---|---|---|
| `haiku` | `low` | trabalho mecânico sem decisão: leitura e busca, docs, coleção de API, ajuste de lint |
| `sonnet` | `medium` | fase de TDD que segue um molde que já existe no repo: endpoint no padrão, service, store, componente com story |
| `opus` | `high` | fase sem molde no repo, ou que toca dinheiro, autorização ou isolamento de tenant, concorrência, lock ou idempotência, integração externa, migração de dados, contrato entre repos |
| `fable` | `high` | só por escalada depois de reprovação em `opus`, ou a pedido do usuário |

Na dúvida entre dois níveis, fique com o de cima.

Marque na coluna Motivo as fases de **risco**: as que foram para `opus` por tocar dinheiro, autorização ou tenant, concorrência, integração externa, migração de dados ou contrato entre repos. Fase em `opus` só por falta de molde não conta. Essa marcação define o tamanho da auditoria em §5.

### Cenário com dado real

Uma fase que lê histórico (tabela de versões, log de eventos, estado anterior de um registro) leva na tabela pelo menos um cenário que gera o histórico pelo fluxo real do domínio, chamando os métodos do model, com sequências que repetem estado ou valor (reprova → reenvia → reprova com o mesmo código, por exemplo). Registro de histórico montado à mão não substitui esse cenário, porque a ferramenta de auditoria costuma gravar só o que mudou.

## 4. Execução por fase

Antes da fase 1, prepare o ambiente você mesmo, como o plano diz em "Ambiente e regras": a branch ou o worktree. Os executores não criam branch; recebem o caminho absoluto do checkout ou do worktree.

Rode as fases uma de cada vez, porque um só agente edita o working tree por vez. Para cada fase:

1. Delegue ao agente `devoso` com o `model` e o `effort` da tabela de roteamento, usando o prompt "Executor de fase" de `implementa-spec/references/prompts-agentes.md`.
2. Avalie a entrega você mesmo, sem confiar no relatório:
   - rode os specs da fase e leia o resultado;
   - leia os arquivos que a fase tocou (os do relatório e o que é novo em `git -C <repo> status --short` desde o retrato da fase anterior) contra a tabela de cenários e as linhas de "Cobertura da SPEC" que ela cobre;
   - confira que o vermelho colado em cada cenário é o "vermelho esperado" do plano;
   - fase que lê histórico: confira que o cenário com dado real existe e passa pelo fluxo do model;
   - confira que nenhum teste da base foi alterado: `git -C <repo> diff <base> --diff-filter=MD --name-only -- <pasta de testes>` tem de voltar vazio;
   - confira as restrições do prompt: git, banco, escopo.
3. Atualize o `PLANO-<id>.md`: tentativas e status da fase (`aprovada` ou `reprovada: <motivo>`), o retrato do `git status --short` e, na fase aprovada, os desvios do plano e as respostas do usuário, que vão para os auditores em §5.

Quando a fase é reprovada:

- **1ª reprovação:** delegue de novo no mesmo modelo, com o feedback concreto (o que falhou, `arquivo:linha`, o que a SPEC pede).
- **2ª reprovação:** suba um nível de modelo (`haiku` → `sonnet` → `opus` → `fable`) e delegue com o histórico das duas tentativas.
- **3ª reprovação:** pare e leve ao usuário o que travou, com a sua recomendação.

Se a delegação em `fable` der erro de acesso, o teto é `opus`: leve ao usuário.

Decisão que é do usuário, surgida no meio de uma fase, vai sozinha e com recomendação, como em `implementa-spec` §4.

## 5. Auditoria, revisão e fechamento

O tamanho da auditoria acompanha o risco marcado no roteamento:

| Plano | Auditoria |
|---|---|
| Nenhuma fase de risco | um `avaliason` em `opus` (`high`), que confere SPEC → código e código → SPEC e corrige em TDD, e o `security-auditor` em `sonnet` (`medium`), só leitura, em paralelo |
| Alguma fase de risco | `implementa-spec` §5 e §6 inteiros: dois `avaliason` em `fable` (`high`), mais os revisores de padrão e performance em `opus` e o `security-auditor` em `opus` (`high`) |

Nos dois casos, o prompt do auditor pede um cenário com dado real para cada leitura de histórico que o diff faz, como em §3. Depois siga `implementa-spec` §7.

A mensagem final traz, além do que `implementa-spec` §7 pede, a tabela de roteamento como terminou: modelo de cada fase, tentativas e escaladas. Ela serve para calibrar a rubrica.
