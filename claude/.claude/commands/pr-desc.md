---
description: Gera descrição de PR (Contexto, Objetivo, features, testes da feature, como testar) a partir da branch atual e diff com origin, usando SPEC_* e spec/<feature> quando existirem.
---

## Diretivas obrigatórias (este comando)

1. **Leia e aplique por completo** a skill **`pr-description-from-branch`**: `~/.cursor/skills/pr-description-from-branch/SKILL.md`.
2. **Use git** contra a base em `origin` (ex.: `origin/main` ou default do remoto); rode `git fetch origin` quando precisar de refs atualizadas.
3. **Incorpore docs** se existirem: `SPEC_*` e `spec/<nome-da-feature>/` (slug alinhado à branch ou ao nome da feature).
4. **Saída** nas secções: **Contexto**, **Objetivo**, **Features implementadas**, **Testes** (só os ligados a esta feature/diff), **Como testar** de uma forma que o usuario possa copiar e colar no git de maneira facil.

Se a branch base do PR for ambígua, pergunte **uma** vez ao utilizador qual usar antes de fechar o texto.
