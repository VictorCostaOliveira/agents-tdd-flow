# Rails + Vue.js — contexto para Claude Code

Este ficheiro faz parte do **bundle Claude** deste repositório. No teu projeto de aplicação, coloca uma cópia na **raiz do repo** como `CLAUDE.md` (ou funde o conteúdo no `CLAUDE.md` existente).

## O que isto define

- Stack mental: **Rails + Vue.js**, TDD (RSpec + Vitest), especificação antes de código quando a demanda for vaga.
- **Regras modulares:** ficheiros em `.claude/rules/*.md` (commits sem autorização, documentação mínima, mapeamento de API, padrões Rails/testes).
- **Agentes (personas):** `.claude/agents/*.md` — requison, devoso, testivos, figoso, avaliason, verifier, etc.
- **Skills (fluxos):** `.claude/skills/<nome>/SKILL.md` — por exemplo `tdd`, `criar-spec`, `levanta-criterios-local`, `postman`.
- **Comandos slash:** `.claude/commands/*.md` — por exemplo `especificar.md` (definir spec antes do código).

## Instalação a partir deste repositório

1. Copia a pasta **`.claude/`** (que está **dentro de `claude/`** neste repo) para a raiz do teu projeto, fundindo com um `.claude/` que já exista.
2. Copia **`claude/CLAUDE.md`** (este ficheiro) para **`CLAUDE.md`** na raiz do projeto de aplicação.
3. Ajusta referências a projetos de exemplo (caminhos, libs internas) ao teu monorepo.

## Caminhos canónicos no projeto (após instalação)

| Tipo | Local |
|------|--------|
| Regras | `.claude/rules/` |
| Agentes | `.claude/agents/` |
| Skills | `.claude/skills/<pasta>/SKILL.md` |
| Comandos | `.claude/commands/` |

## Fluxo sugerido (resumo)

1. **requison** — especificação e critérios de aceite quando o pedido for vago.  
2. **Planeamento / TDD** — alinhar com `arquiteto.md` ou fluxo da skill `tdd` (artefatos `LAYOUT_SPEC.md`, `TESTS.md`, `DEV.md`, `AVALIACAO.md`).  
3. **devoso** — implementação sem alterar testes existentes sem autorização.  
4. **verifier** — validar que “feito” é mesmo feito.  
5. **avaliason** — revisão de código no diff atual.

Consulta o **README na raiz do repositório do bundle** para a visão geral das pastas `cursor/` vs `claude/`.
