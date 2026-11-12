---
name: implementa-spec
description: 'Planeja e executa a implementação exata de uma SPEC em TDD — um cenário por vez: escreve o teste, roda, lê o erro, faz o mínimo que resolve, passa ao próximo —, com o back primeiro. No fim, dois auditores adversariais batem plano × SPEC × implementação e corrigem as divergências, e revisores de padrão do projeto, performance e segurança apontam o que é corrigido na hora. Pede SPEC, PRD e links do Figma quando faltarem. Use sempre que o usuário chamar /implementa-spec, pedir plano de implementação para uma SPEC, falar em implementar ou executar uma SPEC, ou colar uma SPEC ou PRD (com ou sem Figma) para virar código, mesmo sem dizer TDD ou plano. Para escrever a SPEC, use criar-spec ou spec-arquitetura; para o pipeline de front que parte só do Figma, tdd.'
---

# implementa-spec: da SPEC ao código em TDD, com auditoria adversarial

A SPEC é o contrato. Esta skill transforma a SPEC num plano em que cada requisito vira cenário de teste, executa esse plano um cenário por vez e, no fim, põe agentes independentes para procurar onde a implementação se afastou da SPEC, do padrão do projeto, de performance e de segurança. Quem implementa tende a confirmar o próprio trabalho; os auditores partem do contrário.

## O pedido, na forma completa

Ao começar, mostre ao usuário este pedido preenchido com as entradas recebidas, uma vez e curto, e siga:

> Planeje a implementação **exata** da SPEC <SPEC> <e da SPEC mãe, se houver>, com o PRD <PRD> como contexto de produto e o Figma <frames> como referência visual. O que já existe (<branch base, componentes prontos>) é reusado como foi criado. O plano segue TDD, principalmente no back: um cenário por vez — escreve o teste, roda e lê o erro, faz o mínimo que resolve, passa ao próximo. Aprovado o plano, execute até o fim. Depois, dois auditores adversariais batem plano × SPEC × implementação e corrigem as divergências, e revisores apontam o que foge do padrão do projeto, de performance e de segurança, que é corrigido na hora.

## 1. Entradas

| Entrada | Como chega | Se faltar |
|---|---|---|
| SPEC a implementar | link ou arquivo; com SPEC mãe (comum) e filha, as duas | pergunte: a SPEC é o contrato do plano |
| PRD | link ou arquivo | pergunte; "não há PRD" é resposta válida |
| Figma | links com `node-id` dos frames: preenchido, vazio, carregando, erro e os estados de interação | pergunte quando a SPEC tem tela; SPEC só de back segue sem Figma |
| Identificador e base | card ou issue, branch base, o que já está pronto (ex.: componentes de uma fundação) | use o que a SPEC e o git mostram |

Pergunte tudo o que falta numa mensagem só, antes da leitura pesada. Com tudo em mãos, siga direto.

## 2. Leitura

- **SPEC e PRD, você mesmo e por inteiro.** Se estiverem numa wiki, leia pelo MCP correspondente em Markdown. Anote a data da revisão da SPEC. Onde o PRD diverge da SPEC, vale a SPEC, e a divergência vira pergunta no plano.
- **Figma:** `get_screenshot` e `get_metadata` de cada frame; antes de `get_design_context`, carregue a skill de design-to-code do Figma quando existir. Catalogue cada estado: preenchido, vazio, carregando, erro, aberto, selecionado, aplicado. Se o MCP pedir autenticação, peça ao usuário para autorizar ou colar os prints.
- **Código:** o `CLAUDE.md` de cada repo tocado, o código que a SPEC altera, os testes que servem de molde e os componentes que já existem, com a documentação deles (stories, quando existirem).
- **Delegue a leitura do código e do Figma** a agentes `Explore` em paralelo, um por área (padrões do back, infraestrutura de teste do back, componentes do front, Figma × componentes), com perguntas numeradas e resposta em `caminho:linha`. Modelo em `references/prompts-agentes.md`. A SPEC fica com você, porque é ela que o plano traduz.

## 3. O plano

Escreva em plan mode quando houver, que grava o arquivo do plano e pede a aprovação; sem plan mode, grave o plano na pasta da feature e peça a aprovação no chat.

Seções, nesta ordem:

1. **Contexto e fontes:** links, data da revisão da SPEC, o que a revisão fixou, a ordem dos PRs.
2. **Cobertura da SPEC:** tabela `§ da SPEC → fase e cenário do plano`. Todo requisito tem uma linha e todo item do plano aponta para um §. É a lista que os auditores conferem no fim.
3. **0. Antes do código:** tabela `o que | quem | bloqueia`: consulta que só o usuário roda em produção, decisão de produto, revisão do time.
4. **Decisões por padrão:** onde a SPEC deixa aberto, a escolha que vale se o usuário não disser outra coisa. Vai na descrição do PR.
5. **Ambiente e regras:** branch, onde roda (checkout ou worktree, conforme o `CLAUDE.md`), o comando do ciclo (só o arquivo do cenário), os moldes de teste do repo com caminho.
6. **Checklist de endpoint** (quando há API): os cenários que toda rota nova passa, tirados das convenções do repo: permissão, validação, isolamento de tenant, paginação, cache.
7. **Fases**, back primeiro. Cada fase é uma tabela `# | Cenário | Vermelho esperado | Verde`, em que o verde é o mínimo que resolve. "—" no vermelho marca cenário que trava um contrato que já existe e pode nascer verde.
8. **Front:** tabela `frame do Figma → componente existente → props`, com as props como a documentação do componente mostra, e a tabela "A alinhar": `divergência Figma × componente | opção mais simples | o que vale sem o ok`. Mudança em componente compartilhado espera o ok do usuário.
9. **Verificação ponta a ponta:** HTTP real, com um positivo gêmeo para cada negativo, e a tela no browser contra cada frame.
10. **Fechamento e pendências:** lint, specs, docs e coleção de API que o repo exige, perguntas abertas com recomendação.

"Exatamente a SPEC" quer dizer: todo requisito dela está no plano, e o plano só traz o que ela pede. Onde a SPEC conflita com o código, o Figma ou o PRD, o plano registra a pergunta com uma recomendação.

## 4. Execução em TDD

Com o plano aprovado, execute até o fim. Pare só para decisão que é do usuário: a pergunta vai sozinha, com a recomendação.

Ciclo de cada cenário:

1. Escreve o teste do cenário.
2. Roda só esse arquivo e lê o erro. Ele tem de ser o "vermelho esperado" do plano. Vermelho por outro motivo (factory, setup, digitação) não prova nada: conserte o teste e rode de novo.
3. Escreve o mínimo que deixa verde.
4. Roda; verde, passa ao próximo cenário. Refatore só com a suíte verde.

Um cenário por vez porque o erro de cada rodada diz exatamente o que falta; vários cenários juntos misturam as causas.

- **Back:** todo código de produção nasce de um cenário vermelho.
- **Front:** store, service, mapper e componente novo têm spec. A tela usa os componentes existentes do jeito que foram criados, com as props como a documentação do componente mostra. Cada estado do Figma é conferido: peso de fonte, cor de aberto e de selecionado, vazio, carregando, erro.
- Mantenha uma lista curta de desvios do plano, com o que mudou e por quê. Ela vai para os auditores e para o PR.
- Material de apoio (rascunho, saída de agente) fica fora do repositório.

## 5. Auditoria adversarial

Com todas as fases verdes, lance **dois `avaliason`** na mesma mensagem, em paralelo, em modo auditoria. Cada um parte da premissa de que a implementação diverge do plano e da SPEC até provar o contrário, item por item, lendo o código.

- **Back e front:** um auditor por repo. Cada um corrige em TDD só no seu repo e lê o outro como contrato, então as edições não colidem.
- **Um repo só:** um confere SPEC → código (todo requisito está lá, exatamente como a SPEC diz); o outro confere código → SPEC, plano e Figma (tudo o que foi feito tem origem, e a tela bate com os frames e usa os componentes como a documentação deles mostra). O primeiro corrige; o segundo reporta e você aplica, para que um só agente edite o working tree.

O prompt leva:

- o caminho do plano, a SPEC e como buscá-la;
- o repo e a base do diff;
- as restrições (git, comandos, banco, testes existentes);
- as decisões já tomadas, incluindo as respostas do usuário durante a execução, para que não sejam reabertas;
- as pendências do usuário, que o auditor só reporta;
- o formato do relatório.

O modelo completo está em `references/prompts-agentes.md`.

Quando os auditores voltarem, confira o que afirmam lendo o código, rode os specs do módulo e leve ao usuário só o que depende de decisão.

## 6. Revisão: padrão, performance e segurança

Depois da auditoria, lance **três revisores** em paralelo sobre o diff de todos os repos tocados, um por dimensão. Para segurança, use o `security-auditor`; para os outros, `general-purpose`.

- **Padrão do projeto:**
  - regras do `CLAUDE.md` e de `.claude/rules/`, citando a regra;
  - camadas: model enxuto, consulta em service ou query object, controller e concern finos;
  - reuso do que já existe, nomeando o helper ou o componente;
  - componente do design system usado como a documentação dele mostra;
  - todo texto no i18n, inclusive mensagem de erro de API;
  - abstração sem necessidade concreta.
- **Performance:** N+1, consulta sem índice ou sem limite, trabalho repetido por request ou por linha, cache, tamanho do payload, request duplicado ou disparado no mount.
- **Segurança:** autorização por rota, isolamento de tenant, validação na borda, input refletido em erro ou log, PII em log, segredo, XSS, SQL montado com string.

Os revisores leem e devolvem achados com `arquivo:linha`, cenário concreto e a correção mais simples. Você confere cada achado e aplica os reais na hora, com teste primeiro quando a correção muda comportamento, e roda os specs afetados e o lint. As correções ficam com você porque três agentes editando o mesmo working tree colidem, e só você tem no contexto as decisões do plano.

Quando a ferramenta `ReportFindings` existir, registre os achados nela, cada um com `outcome`: `fixed`, `skipped` ou `no_change_needed`.

## 7. Fechamento

- Rode os specs do módulo e o lint de cada repo; confira o banco e o schema como o repo exige.
- Se o contrato HTTP mudou, atualize docs e coleção de API na mesma mudança.
- Commit, PR e migration só com autorização explícita. A descrição do PR sai da skill `pr-desc`.
- Mensagem final curta, com:
  - o que foi entregue em cada fase;
  - o que a auditoria e a revisão corrigiram;
  - as pendências, com recomendação;
  - o lembrete de atualizar o card ou a issue.
