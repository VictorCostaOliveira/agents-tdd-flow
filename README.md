# Bundle de agentes — Cursor e Claude

Repositório com **dois pacotes paralelos** para o mesmo conjunto de ideias (Rails + Vue.js, TDD, especificação antes de código, revisão e segurança):

| Pasta | Ferramenta | Conteúdo |
|--------|------------|----------|
| **`cursor/`** | [Cursor](https://cursor.com) | Regras `.mdc`, agentes, skills e comandos no formato Cursor. |
| **`claude/`** | [Claude Code](https://code.claude.com/docs) | O mesmo material adaptado: `CLAUDE.md` + diretório `.claude/` com regras `.md`, agentes, skills e comandos. |

Não é uma aplicação: é **configuração reutilizável** (personas, fluxos e regras) para copiares para o teu projeto ou perfil de IDE.

---

## O que cada pasta faz

### `cursor/`

- **`cursor/rules/`** — regras persistentes (frontmatter YAML + Markdown `.mdc`): commits só com permissão, documentação mínima, contratos de API no frontend, padrões Rails e testes.
- **`cursor/agents/`** — definições de “agentes” (Markdown): requison, devoso, testivos, figoso, avaliason, verifier, arquiteto, infrason, cobrinha, wiki, revisores, Postman, segurança, etc., mais **`cursor/agents/knowledge/`** com notas de arquitetura, Rails, Vue e checklists.
- **`cursor/skills/`** — skills por pasta com `SKILL.md` (fluxos como TDD completo, criar spec, Postman, critérios com Figma).
- **`cursor/commands/`** — comandos personalizados (ex.: especificação antes do código).

**Como usar no Cursor:** copia ou sincroniza para o `.cursor/` do projeto ou do utilizador (`~/.cursor`), mantendo a mesma estrutura relativa (`rules`, `agents`, `skills`, `commands`). Detalhes longos dos agentes e fluxos: **`cursor/README.md`**.

### `claude/`

- **`claude/CLAUDE.md`** — instruções de projeto para o Claude Code; copia para a **raiz** do repo da aplicação como `CLAUDE.md`.
- **`claude/.claude/rules/`** — mesmas regras que em `cursor/rules/`, em `.md` (sem frontmatter Cursor).
- **`claude/.claude/agents/`** — cópia adaptada dos agentes; referências internas usam caminhos `.claude/...` em vez de `.cursor/...`.
- **`claude/.claude/skills/`** — skills com o mesmo conteúdo, com paths e menções a subagentes ajustados ao Claude Code.
- **`claude/.claude/commands/`** — comandos slash (ex.: `especificar.md`).

**Como usar no Claude Code:** funde `claude/.claude/` com o `.claude/` do teu projeto e coloca `claude/CLAUDE.md` na raiz como `CLAUDE.md`.

---

## Mapa rápido de ficheiros

```
.
├── README.md                 # Este ficheiro — visão geral do repositório
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

- Alterações conceituais (novo agente, nova regra) devem ser reflectidas **nos dois lados** (`cursor/` e `claude/`) ou documentadas se só fizer sentido num deles.
- Ficheiros `.mdc` no Cursor têm metadados no topo; em `claude/.claude/rules/` o corpo é Markdown simples.

---

## Licença

Uso interno / customização livre conforme a tua organização.
