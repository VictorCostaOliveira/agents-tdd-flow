---
name: feature
description: 'Comando único do PRD à feature pronta, com a sessão como manager: faz o grill do PRD até a SPEC, monta o plano em TDD com o modelo e o effort escolhidos para cada fase, delega cada fase ao devoso nesse modelo, avalia o que voltou antes de liberar a próxima e escala o modelo quando a entrega é reprovada. Para na aprovação da SPEC e na do plano; no modo autônomo (o usuário dispensa as aprovações), responde o grill pelos critérios de aceite da issue, do PRD e das issues passadas e troca os gates por uma matriz critério → SPEC → cenário, em worktree, até o fim. Use quando o usuário chamar /feature, colar um link de issue ou um PRD (com ou sem Figma) pedindo para levar até a feature pronta, ou pedir o fluxo completo PRD → SPEC → plano → TDD com roteamento de modelos. A SPEC sai no padrão da spec-arquitetura e o plano exatamente como o da implementa-spec. Para só escrever a SPEC, use spec-arquitetura; para implementar uma SPEC já pronta sem roteamento, use implementa-spec.'
---

# feature — do PRD à feature pronta, com a sessão como manager

A sessão principal é o manager: conversa com o usuário, decide o modelo de cada tarefa, delega e avalia. Os agentes executam: `devoso` implementa cada fase, `avaliason` e `security-auditor` auditam no fim. Rode numa sessão em **Opus**, porque o grill, o plano e a avaliação acontecem aqui.

Esta skill orquestra o que já existe: a SPEC vem de `spec-arquitetura` (`.claude/skills/spec-arquitetura/SKILL.md`), e o plano, a auditoria e o fechamento vêm de `implementa-spec` (`.claude/skills/implementa-spec/SKILL.md`). Leia as seções citadas de lá quando chegar nelas.

## 1. Entradas

| Entrada | Se faltar |
|---|---|
| Identificador da feature (card, issue ou link) | pergunte; dá nome à pasta, à SPEC e à branch |
| PRD (link ou arquivo) | tire da issue; se não houver, pergunte; é a fonte do grill |
| Figma (links com `node-id`) | tire da issue ou do PRD; pergunte quando a feature tem tela e nenhum dos dois traz |
| SPEC mãe, se a feature for filha | use a que o PRD ou o card citam |

Com link de issue, leia a issue no tracker (descrição, critérios de aceite, épico, issues e links ligados) antes de perguntar qualquer coisa. Pergunte tudo o que falta numa mensagem só. Tudo desta feature mora em `<pasta de specs>/<id>-<slug>/`.

**Retomada:** se a pasta já tem `PLANO-<id>.md`, leia o plano e siga da primeira fase com status diferente de `aprovada`. Se só tem a SPEC, siga do passo que falta.

## 2. SPEC com grill

1. Leia o PRD por inteiro e o código que ele toca. Delegue a leitura do código a agentes `Explore` com `model: haiku`, como em `implementa-spec` §2.
2. Grill: uma pergunta por vez, cada uma com a sua recomendação, até não restar decisão aberta. Fato que o repo responde, você levanta, sem perguntar.
3. Escreva a SPEC seguindo a skill `spec-arquitetura`: o "Como gerar" dela (contexto real do repo, `arquiteto` nos trade-offs, `N/A — <motivo>` no que não se aplica, premissas à vista) e o template com as 10 áreas. O que o grill decidiu vai para a área correspondente. Grave em `SPEC-<id>.md` na pasta da feature, em vez do `SPEC_ARQUITETURA.md` que a skill sugere.
4. **Gate 1:** o usuário aprova a SPEC local. Publicar em outra ferramenta (wiki) só com o ok dele. Daqui em diante, o plano e os auditores leem a versão publicada; sem publicação, a fonte é o `SPEC-<id>.md` local, e os prompts apontam para esse caminho.

## 3. Plano com roteamento

Leia `implementa-spec` §3 e monte o plano exatamente como ela pede, em plan mode: as dez seções, na mesma ordem, e cada fase com a tabela `# | Cenário | Vermelho esperado | Verde`, um cenário por vez, back primeiro. Toda área e todo requisito da SPEC têm linha em "Cobertura da SPEC". Grave uma cópia em `PLANO-<id>.md` na pasta da feature.

Esta skill acrescenta **Roteamento**, logo depois de "Cobertura da SPEC", e, no modo autônomo (§6), a **Matriz de critérios** logo depois dele; nenhuma seção da §3 sai nem muda:

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

## 6. Modo autônomo — guiado pelos critérios de aceite

Vale quando o usuário dispensa as aprovações ("a SPEC e o plano não precisam de aprovação", "pode ir até o final sem pedir permissão"). Link de issue sozinho não liga este modo. Ligado, o fluxo de §2 a §5 continua igual, com estas trocas:

**Fontes do grill, nesta ordem:** critérios de aceite da issue → critérios e regras do PRD (e respostas nos comentários) → issues passadas: irmãs no mesmo épico, issues ligadas e as SPECs já na pasta de specs.

1. **Grill autorrespondido.** Uma pergunta por vez, com recomendação, mas quem responde é você, pelas fontes acima, citando de onde veio cada resposta (`CA-3 da issue`, `PRD §Regras`, `<id da issue passada>`). Registre perguntas e respostas na seção de decisões da SPEC.
   - Pergunta que nenhuma fonte cobre: a sua recomendação vira **premissa** visível na SPEC, sem parar.
   - Fontes em conflito: vale a issue; registre o conflito na SPEC.
2. **Critérios numerados.** Liste os critérios de aceite da issue como `CA-1..n` no topo da SPEC, com o texto original. Critério do PRD que a issue não traz entra como `PRD-n`.
3. **Plano sem plan mode.** Escreva o `PLANO-<id>.md` direto (plan mode prende na aprovação). Cada cenário da tabela começa pelo critério que prova: `CA-2: usuário sem permissão recebe 403`. Os cenários são escritos a partir do texto do critério, cobrindo o caminho feliz e as bordas que o critério nomeia.
4. **Matriz de critérios** (no plano, depois do Roteamento):

   | Critério | Área / requisito da SPEC | Cenário(s) do plano |
   |---|---|---|
   | CA-1 | APIs — `GET /...` | 2.1, 2.3 |

   Ela substitui os gates 1 e 2. Passa quando todo `CA`/`PRD` tem ao menos um cenário, e todo requisito e cenário aponta para um critério, o PRD, uma issue passada ou uma premissa listada. Reprovou: corrija a SPEC ou o plano e confira de novo. Passou: marque no plano `Gate 1 e 2: aprovados por critério` e siga.
5. **Sem publicação.** A SPEC fica local; publicar vira pendência na mensagem final.
6. **Worktree sempre.** `git -C <repo> worktree add <pasta de worktrees>/<repo>-<slug> -b <branch>` em cada repo tocado. Os executores recebem esses caminhos; nada roda no checkout base.
7. **Até o fim, em primeiro plano.** Executores em primeiro plano; avalie, siga para a próxima fase, depois auditoria, revisão e fechamento, sem encerrar a resposta entre fases.
8. **Paradas que continuam valendo:** commit, push e PR; escrita no tracker ou na wiki; formato de migration e a execução dela. Se a SPEC tem migration, faça logo depois da matriz uma pergunta só, com recomendação (colunas, tipos, índices e o ok para migrar no ambiente local), e siga ao receber a resposta, porque migration pendente quebra todo spec. A parada na 3ª reprovação de uma fase (§4) também continua.
9. **Fechamento.** Com nada commitado, o worktree fica sujo: mantenha e informe os caminhos. A mensagem final traz, além de §5: premissas tomadas, conflitos entre fontes, a matriz como terminou, os caminhos dos worktrees e as autorizações pendentes (commit/PR, publicação da SPEC, atualização da issue).
