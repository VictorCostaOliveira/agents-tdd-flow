# agents-tdd-flow

Agentes, skills e regras para desenvolver Rails + Vue com TDD no **Claude Code** e no **Cursor**: o artefato de cada etapa é escrito antes do código, e o fluxo para entre etapas até você aprovar.

Não é uma aplicação. É configuração para copiar para o seu projeto ou para o seu perfil.

## O fluxo

```
  /criar-spec                         /tdd
 ┌───────────┐   ┌────────┐  ┌──────────┐  ┌────────┐  ┌────────┐  ┌───────────┐
 │ requison  │──▶│ figoso │─▶│ testivos │─▶│ devoso │─▶│ refoso │─▶│ avaliason │
 │ SPEC.md   │   │ LAYOUT │  │ TESTS.md │  │ DEV.md │  │REFACTOR│  │ AVALIACAO │
 └───────────┘   │ _SPEC  │  │ + testes │  │+ código│  │  .md   │  │   .md     │
                 └────────┘  └──────────┘  └────────┘  └────────┘  └───────────┘
                      ▲            ▲            ▲           ▲            ▲
                   aprovação   aprovação    aprovação   aprovação    aprovação
```

Cada agente grava o seu `.md` na pasta da feature e só depois mexe em código. O testivos entrega em dois passos: primeiro o `TESTS.md` em árvore, depois os arquivos de teste, que ficam vermelhos até o devoso implementar. Ao final, o **verifier** confirma que o que foi declarado pronto funciona e o **security-auditor** revisa o diff.

Exemplo de `TESTS.md`:

```text
### A. `OrderItemModal`

describe('OrderItemModal')
  context('when closed')
    it('does not render the modal content')
  context('when open')
    it('shows the item name and price')
    it('emits close when the overlay is clicked')
```

## Instalação

**Claude Code**

```bash
./install.sh                          # pergunta agente por agente e skill por skill; destino ~/.claude
./install.sh --all                    # tudo
./install.sh devoso testivos tdd      # só esses
./install.sh --to <projeto> --all     # no .claude/ do projeto
```

Agente instalado leva junto `agents/knowledge/`. As regras e o `CLAUDE.md` são copiados à mão:

```bash
cp -R claude/.claude/rules <projeto>/.claude/rules
cp claude/CLAUDE.md <projeto>/CLAUDE.md   # ou funda com o CLAUDE.md existente
```

**Cursor**

```bash
cp -R cursor/rules  <projeto>/.cursor/rules
cp -R cursor/agents <projeto>/.cursor/agents
cp -R cursor/skills ~/.cursor/skills
```

Pré-requisito para o figoso, o criar-criterios e o criar-spec com design: o MCP do Figma configurado no editor.

## Agentes

Mascote para quem está no pipeline, nome de cargo para apoio.

| Agente | Papel | Modelo (Claude Code) |
|---|---|---|
| **requison** | Levanta requisitos e critérios de aceite; Fase 1 do `/criar-spec` | opus / high |
| **figoso** | Lê o Figma via MCP e grava `LAYOUT_SPEC.md` | sonnet / medium |
| **testivos** | `TESTS.md` em árvore e depois os testes, vermelhos | sonnet / medium |
| **devoso** | Implementa até os testes passarem, sem alterar testes | sonnet / medium |
| **refoso** | `REFACTOR.md` e refatoração com a suíte verde | sonnet / medium |
| **avaliason** | Auditoria adversarial do diff contra SPEC, plano e critérios; `AVALIACAO.md` | opus / high |
| **arquiteto** | Decisão de arquitetura, sempre com mais de uma opção | opus / high, só leitura |
| **verifier** | Confirma que o que foi declarado pronto funciona de verdade | sonnet / high, só leitura |
| **security-auditor** | Vulnerabilidades exploráveis no diff, no estilo OWASP | opus / high, só leitura |

No Cursor os agentes usam `model: inherit`, e os de só leitura levam `readonly: true`.

`agents/knowledge/` guarda os checklists que avaliason, refoso e security-auditor consultam quando o repositório não responde: SOLID, segurança, qualidade de código e plano de remoção.

## Skills

Cada skill é um comando slash com o mesmo nome, no Claude Code e no Cursor (`/tdd`, `/criar-spec`…).

| Skill | Faz |
|---|---|
| **`tdd`** | O pipeline acima, com os agentes e os gates |
| **`criar-spec`** | Spec antes do código; Fase 1 com o requison, fluxo do Figma quando houver design |
| **`spec-arquitetura`** | Technical design doc em 10 áreas para sistema, serviço ou integração nova; trade-offs com o arquiteto |
| **`implementa-spec`** | Da SPEC ao código: plano com cobertura da SPEC, TDD um cenário por vez, dois auditores adversariais e revisores de padrão, performance e segurança |
| **`criar-criterios`** | Objetivos e critérios de aceite por funcionalidade a partir do Figma |
| **`pr-desc`** | Descrição de PR a partir da branch e do diff com `origin` |
| **`postman`** | Collection do Postman a partir das rotas, controllers e strong params de uma API Rails |
| **`feature`** (só Claude Code) | Do PRD à feature pronta: grill até a SPEC, plano com modelo e effort por fase, execução delegada ao devoso com avaliação de cada fase |

## Regras

`rules/` traz quatro regras que valem em todo o repositório: commit só com autorização, documentação mínima, mapeamento de API pelo contrato, e padrões de Rails e testes (métodos curtos, testes existentes intocáveis, migrations só por generator e com autorização).

## Estrutura

```
.
├── claude/                 # fonte de verdade
│   ├── CLAUDE.md           # template para a raiz do projeto
│   └── .claude/
│       ├── agents/         # 9 agentes + knowledge/
│       ├── skills/         # 8 skills
│       └── rules/          # 4 regras
├── cursor/                 # gerado por scripts/to_cursor.py
│   ├── agents/
│   ├── skills/
│   └── rules/              # .mdc
├── install.sh              # instala agentes e skills do Claude, com escolha
├── scripts/to_cursor.py
└── Makefile                # make cursor | make check
```

## Manutenção

Edite em `claude/` e rode `make cursor`. O `make check` falha quando `cursor/` está diferente do que `claude/` gera. Nada em `cursor/` é editado à mão.

Idioma: português nos agentes, skills, regras e commits (`tipo(escopo): descrição`); inglês nos identificadores de código.

## Licença

MIT.
