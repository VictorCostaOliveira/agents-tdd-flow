# Bundle de agentes — Cursor e Claude

Repositório com **dois pacotes paralelos** para o mesmo conjunto de ideias (Rails + Vue.js, TDD, especificação antes de código, revisão e segurança):

| Pasta | Ferramenta | Conteúdo |
|--------|------------|----------|
| **`cursor/`** | [Cursor](https://cursor.com) | Regras `.mdc`, agentes, skills e comandos no formato Cursor. |
| **`claude/`** | [Claude Code](https://code.claude.com/docs) | O mesmo material adaptado: `CLAUDE.md` + diretório `.claude/` com regras `.md`, agentes, skills e comandos. |

Não é uma aplicação: é **configuração reutilizável** (personas, fluxos e regras) para copiares para o teu projeto ou perfil de IDE.

---

## Skills (`skills/<nome>/SKILL.md`)

| Skill | Função |
|-------|--------|
| **`test-driven-development`** | Pipeline TDD com **agentes** (Task): figoso → testivos → devoso → refoso → avaliason; artefatos `LAYOUT_SPEC.md`, `TESTS.md`, `DEV.md`, `REFACTOR.md`, `AVALIACAO.md`. |
| **`test-driven-development-skills`** | Mesmo pipeline **sem subagentes**: uma skill por etapa (`tdd-layout-spec`, `tdd-tests-plan`, `tdd-tests-implement`, `tdd-dev`, `tdd-refactor`, `tdd-avaliacao`). |
| **`criar-spec`** | Spec antes do código; Fase 1 costuma ir ao **requison**. |
| **`cria-criterios`** | Objetivos e critérios de aceite a partir do **Figma** (MCP). |
| **`pr-description-from-branch`** | Texto de PR a partir da branch (diff + `SPEC_*` / `spec/<feature>/` quando existirem). |
| **`postman`** | Coleção Postman a partir da API Rails. |

---

## Comandos (`commands/*.md`)

| Comando | Arquivo | Notas |
|---------|---------|--------|
| `/tdd` | `tdd.md` | Usa agentes + skill `test-driven-development`. |
| `/do-tdd` | `do-tdd.md` | Usa skills `test-driven-development-skills` (sem Task). |
| `/especificar` | `especificar.md` | Spec antes do código + **requison**; alinha com **cria-criterios** se houver Figma. |
| `/cria-criterios` | `cria-criterios.md` | Atalho para a skill **cria-criterios**. |
| `/pr-desc` | `pr-desc.md` | Atalho para **pr-description-from-branch**. |

---

## TDD — resumo do fluxo

1. **Layout:** **figoso** / `tdd-layout-spec` → `LAYOUT_SPEC.md`.
2. **Testes — plano:** **testivos** Fase A / `tdd-tests-plan` → `TESTS.md` em **árvore** (`### A.`… + bloco `text` com `describe` / `context` / `it`).
3. **Testes — código:** **testivos** Fase B / `tdd-tests-implement` → arquivos `.spec` / RSpec; **sem** código de produção na mesma fase; suíte pode ficar **vermelha** até ao dev.
4. **Implementação:** **devoso** / `tdd-dev` → `DEV.md` e código até testes **verdes** (sem alterar testes sem autorização).
5. **Refatoração:** **refoso** / `tdd-refactor` → `REFACTOR.md` e refatoração segura.
6. **Review:** **avaliason** / `tdd-avaliacao` → `AVALIACAO.md`.

Entre etapas há **gate de aprovação** (documentado nas skills e no agente **testivos**). Ver também **`claude/CLAUDE.md`**.

---

## O que cada pasta faz

### `cursor/`

- **`cursor/rules/`** — regras persistentes (frontmatter YAML + Markdown `.mdc`): commits só com permissão, documentação mínima, contratos de API no frontend, padrões Rails e testes.
- **`cursor/agents/`** — definições de agentes (Markdown): requison, devoso, testivos, figoso, avaliason, verifier, arquiteto, infrason, cobrinha, wiki, revisores, Postman, segurança, etc., mais **`cursor/agents/knowledge/`** com notas de arquitetura, Rails, Vue e checklists.
- **`cursor/skills/`** — skills por pasta com `SKILL.md` (TDD completo, TDD por skills, criar spec, critérios Figma, descrição de PR, Postman).
- **`cursor/commands/`** — comandos personalizados (`tdd`, `do-tdd`, `especificar`, `cria-criterios`, `pr-desc`).

**Como usar no Cursor:** copia ou sincroniza para o `.cursor/` do projeto ou do utilizador (`~/.cursor`), mantendo a mesma estrutura relativa (`rules`, `agents`, `skills`, `commands`). Mais detalhe: **`cursor/README.md`**.

### `claude/`

- **`claude/CLAUDE.md`** — instruções de projeto para o Claude Code; copia para a **raiz** do repo da aplicação como `CLAUDE.md`.
- **`claude/.claude/rules/`** — mesmas regras que em `cursor/rules/`, em `.md` (sem frontmatter Cursor).
- **`claude/.claude/agents/`** — cópia dos agentes; referências internas usam caminhos `.claude/...` em vez de `.cursor/...`.
- **`claude/.claude/skills/`** — skills com o mesmo conteúdo que em `cursor/skills/`.
- **`claude/.claude/commands/`** — comandos slash (mesmos nomes que em `cursor/commands/`).

**Como usar no Claude Code:** funde `claude/.claude/` com o `.claude/` do teu projeto e coloca `claude/CLAUDE.md` na raiz como `CLAUDE.md`.

---

## Mapa rápido de arquivos

```
.
├── README.md                 # Este arquivo — visão geral do repositório
├── cursor/
│   ├── README.md             # Documentação extensa dos agentes e fluxos (Cursor)
│   ├── rules/*.mdc
│   ├── agents/**/*.md
│   ├── skills/*/SKILL.md
│   └── commands/*.md
└── claude/
    ├── CLAUDE.md             # Copiar para ./CLAUDE.md no projeto alvo
    └── .claude/
        ├── rules/*.md
        ├── agents/**/*.md
        ├── skills/*/SKILL.md
        └── commands/*.md
```

---

## Manutenção

- Alterações conceituais (novo agente, nova regra, nova skill) devem ser reflectidas **nos dois lados** (`cursor/` e `claude/`) ou documentadas se só fizer sentido num deles.
- Arquivos `.mdc` no Cursor têm metadados no topo; em `claude/.claude/rules/` o corpo é Markdown simples.

---

## Licença

Uso interno / customização livre conforme a tua organização.
