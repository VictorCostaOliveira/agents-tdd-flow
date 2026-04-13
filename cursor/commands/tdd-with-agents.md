---
description: Fluxo TDD completo (Figma → testes → implementação → refatoração → avaliação) com agentes dedicados e validação de artefatos entre etapas.
---

## Diretivas obrigatórias (este comando)

1. **SEMPRE CHAME OS AGENTES PARA SUAS DEVIDAS TAREFAS** — cada etapa do pipeline corresponde a um agente (`figoso`, `testivos`, `devoso`, `refoso`, `avaliason`). Use o **Task tool** com o `subagent_type` correto para cada um; **não** substituir o trabalho do agente no lugar certo.
2. **SEMPRE PEÇA A VALIDAÇÃO DO ARTEFATO PARA O USUÁRIO ANTES DE SEGUIR A TAREFA** — após cada entrega (documento e/ou código da etapa), **parar**, apresentar resumo e paths, e **só continuar** com **aprovação explícita** do usuário.
3. **ARTEFATO ANTES DA EXECUÇÃO** — em cada etapa com plano (`.md`), o arquivo deve estar **gravado no disco** e ser o que **define** o trabalho; **proibido** implementar/refatorar primeiro e só depois “documentar o que foi feito”. Ver seção *Princípio inviolável* na skill.
4. **TESTIVOS EM DOIS PASSOS** — primeiro: **só** `TESTS.md` em **árvore** (ver `~/.cursor/agents/testivos.md`); depois da **aprovação**, **testivos** Fase B: arquivos de teste reais — **sem** código de produto nem mínimo para verde; falhas ao rodar são **esperadas** até o **devoso**. Ver etapa 2 da skill.

## Skill a seguir

Leia e aplique **por completo** a skill **`test-driven-development`**:

- Arquivo: `~/.cursor/skills/test-driven-development/SKILL.md` (pasta = nome da skill).

Use o pedido do usuário (Figma, objetivo, critérios de aceite, pasta da feature) como input; se faltar algo essencial, pergunte antes de avançar.
