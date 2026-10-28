# Prompts dos agentes

Modelos para as fases 2, 5 e 6 do `SKILL.md`, e o executor de fase da skill `feature`. Preencha os `<...>` com o que o plano e a sessão já têm e tire do prompt o que não se aplica. O agente não vê esta conversa: tudo o que ele precisa saber vai no prompt.

## Leitor (fase 2): `Explore`

```
Contexto: vamos planejar a implementação (TDD) de <o que a SPEC entrega> em <repo e caminho absoluto>, <stack>. Só leitura: não edite nada.

Quero um relatório objetivo, com `caminho:linha` e trechos curtos, respondendo a cada item. Se algo não existir, diga que não existe.
1. <pergunta concreta: padrão de rota, controller, policy ou model que a SPEC toca>
2. <pergunta concreta: molde de teste, factories, helpers, como testar 403 e 422>
3. <...>
```

Para o leitor de Figma, acrescente:

```
Figma: file key <...>. Frames: <node-id — estado>, <node-id — estado>.
Use `get_screenshot` e `get_metadata`. Antes de `get_design_context`, carregue a skill de design-to-code do Figma quando existir.
Para cada frame, responda:
1. qual componente existente cobre e com quais props e slots, conferidos na documentação do componente (story, quando existir);
2. o que o Figma mostra que o componente não faz, com `arquivo:linha` do componente.
Divergência vira item "a alinhar". Descreva o desenho como está.
Saída: tabela frame → componente → props → divergências, e no fim a lista "a alinhar", da de maior impacto para a de menor.
```

## Executor de fase (skill `feature`): `devoso`, modo fase

Um por fase do plano, um de cada vez. O `model` e o `effort` vêm da tabela de roteamento do plano.

```
Você implementa a fase <n — título> de <identificador da feature> em TDD, em <repo e caminho absoluto>, branch <...>. As outras fases não são suas.

## Fontes
- Plano aprovado: <caminho do plano>. A sua fase é a seção <...>: a tabela `# | Cenário | Vermelho esperado | Verde` é o seu escopo inteiro. Leia também "Decisões por padrão" e "Ambiente e regras".
- SPEC: <caminho ou link>, seções <...>.
- Moldes no repo: <arquivos de teste e de código que a fase copia>.
<- Retentativa: a entrega anterior foi reprovada por <motivo, arquivo:linha, o que a SPEC pede>. Corrija isso primeiro.>

## Ciclo, um cenário por vez
1. Escreve o teste do cenário.
2. Roda só esse arquivo e lê o erro. Ele tem de ser o "vermelho esperado". Vermelho por outro motivo (factory, setup, digitação): conserte o teste e rode de novo.
3. Escreve o mínimo que deixa verde.
4. Roda; verde, passa ao próximo cenário.

## Restrições
- Git: nada de commit, push, stash, checkout, switch, reset, rebase nem branch nova. Use sempre `git -C <repo>`.
- Comandos: <comando de teste e de lint do repo>. Rode só os specs da fase.
- Banco: sem migration e sem `db:*`. Se a fase precisar de migration, pare e reporte.
- Testes: teste que já existe na base não se altera, não se apaga e não se comenta.
- Estilo: <CLAUDE.md do repo> e as regras de `.claude/rules`. Nenhum comentário novo no código. A solução mais simples que resolve, sem abstração nova e sem nada além da tabela da fase.
- Decisão que não está no plano nem na SPEC: pare e reporte, com a sua recomendação.

## Relatório final (curto)
1. Tabela por cenário: # · vermelho obtido (a linha do erro, colada da saída) · arquivos do verde (`arquivo:linha`).
2. Saída final dos specs da fase: contagem de exemplos e falhas.
3. Desvios do plano, com o motivo.
4. Pendências para o usuário, com recomendação.
```

## Auditor adversarial (fase 5): `avaliason`, modo auditoria

Um por repo quando há back e front. Com um repo só, use duas direções (SPEC → código e código → SPEC); a segunda recebe "Só leitura: não edite; devolva a tabela" no lugar da parte 2 do trabalho.

```
Você é um auditor adversarial do <back|front> de <identificador da feature> (<título>). Parta desta premissa: a implementação diverge do plano e da SPEC até você provar o contrário, item por item, lendo o código. Seu trabalho tem três partes:
1. comparar plano, SPEC e implementação;
2. corrigir, em TDD, toda divergência cuja resposta está clara nas fontes e não depende de decisão do usuário;
3. devolver um relatório curto.

## Fontes (leia todas antes de julgar)
- Plano aprovado: <caminho do arquivo do plano>. Valem as seções <...>. A tabela "Cobertura da SPEC" é o ponto de partida do seu checklist.
- SPEC: <caminho ou link, e como ler>. Seções que importam: <...>.
- <Front: frames do Figma <node-id — estado>, com `get_screenshot`; a documentação (stories) de cada componente usado.>
- Onde plano e SPEC divergem, vale a SPEC. A exceção é a divergência que exige migration ou decisão do usuário: essa entra só no relatório.
- Implementação: <repo>, branch <...>, sem commit. Veja o estado com `git -C <repo> status --short` e `git -C <repo> diff <base>`, e leia também os arquivos não rastreados. Arquivos centrais: <lista>.
- Contrato do outro lado, só leitura: <repo e caminhos>. Outro agente pode estar mexendo nele. Se achar que o contrato diverge da SPEC, reporte; o seu lado segue o contrato que existe.

## Restrições
- Git: nada de commit, push, stash, checkout, switch, reset, rebase nem branch nova. Use sempre `git -C <repo>`. <Arquivos do usuário que ficam intocados: ...>
- Comandos: <comando de teste e de lint do repo>. Rode só os specs necessários, um de cada vez.
- Banco: sem migration e sem `db:*`.
- Testes: teste que já existe na base não se altera, não se apaga e não se comenta. Specs criados nesta branch podem ser ajustados só para alinhar com a SPEC ou o plano, com a justificativa no relatório.
- Estilo: <CLAUDE.md do repo> e as regras de `.claude/rules`. Nenhum comentário novo no código. A solução mais simples que resolve, sem abstração nova e sem escopo além da SPEC.
- <Front: a tela usa os componentes existentes como foram criados, com as props como a documentação do componente mostra. Mudança em componente compartilhado é decisão do usuário.>
- Contrato HTTP: se uma correção mudar rota, parâmetro, forma ou chave do payload, atualize na mesma mudança <docs e coleção de API do repo> e diga isso na primeira linha do relatório.

## Decisões já tomadas (não reabrir)
<"Decisões por padrão" do plano, respostas do usuário durante a execução, achados de revisão já aplicados>

## Pendências que dependem do usuário (só reportar)
<lista>

## Procedimento
1. Monte o checklist a partir da tabela "Cobertura da SPEC" do plano e das seções citadas.
2. Para cada item, leia o código de verdade (o arquivo, não só o grep) e classifique:
   - conforme;
   - divergente, a corrigir;
   - divergente, decisão do usuário;
   - fora do escopo deste PR.
3. Para cada divergência a corrigir: escreve ou ajusta o cenário, roda e lê o vermelho, faz o mínimo que resolve, fica verde, passa ao próximo.
4. No fim, rode <specs do módulo>, <lint nos arquivos alterados> e <checagem do banco>.

## Relatório final (até ~80 linhas)
1. Primeira linha: "Contrato HTTP alterado: sim/não", com o detalhe se sim.
2. Tabela de divergências: # · fonte (documento e §) · o que a fonte diz · o que o código fazia · ação (corrigido em `arquivo:linha` / decisão do usuário / sem mudança). Os itens conformes mais relevantes vão agrupados numa linha.
3. Specs ajustados desta branch, com a justificativa.
4. Resultado de verdade: contagem de exemplos e falhas, saída do lint e do banco.
5. Pendências para o usuário, com recomendação.

Rascunho, se precisar, fica fora do repo; o relatório vem na resposta.
```

## Revisor (fase 6): `general-purpose` ou `security-auditor`

Um por dimensão: padrão do projeto, performance, segurança. Os três rodam em paralelo e só leem; quem aplica as correções é o agente principal.

```
Você revisa o diff de <identificador da feature> na dimensão **<padrão do projeto | performance | segurança>**. Só leitura: não edite arquivo e não rode comando que altere arquivo, banco ou git.

Escopo:
- <repo 1>: `git -C <repo 1> diff <base>` e os arquivos não rastreados (`git -C <repo 1> status --short`).
- <repo 2>: idem, contra <base>.

Leia antes: o plano em <caminho>, seção "Decisões por padrão". O que está decidido ali não é achado. <Padrão: o CLAUDE.md de cada repo e `.claude/rules/*.md`.>

Procure:
<padrão do projeto>
- violação de regra do CLAUDE.md e de `.claude/rules`, citando a regra e o arquivo onde ela mora;
- código na camada errada: model inchado, consulta fora de service ou query object, controller ou concern fazendo trabalho de service;
- reimplementação do que já existe, nomeando o helper ou o componente existente;
- componente do design system recriado, ou usado diferente da documentação dele;
- texto fora do i18n, inclusive mensagem de erro de API;
- abstração, configuração ou generalização sem necessidade concreta.
<performance>
- N+1; consulta sem índice, sem limite ou sem paginação;
- trabalho repetido por request, por linha ou por render;
- cache ausente onde a SPEC pede, ou cache com chave errada;
- payload maior que o necessário;
- request duplicado ou disparado no mount sem necessidade.
<segurança>
- rota sem autorização ou com a permissão errada;
- dado de outro tenant alcançável;
- validação ausente na borda;
- input do usuário refletido em erro ou log; PII em log;
- segredo no código; XSS (`v-html`); SQL montado com string; mass assignment.

Cada achado traz:
- `arquivo:linha`;
- o problema numa frase;
- o cenário concreto (entrada ou estado → resultado errado ou custo);
- a correção mais simples.
Achado sem cenário nomeável fica de fora.

Saída: até 10 achados, do mais grave ao menos grave. O relatório vem na resposta, sem arquivo no repo.
```
