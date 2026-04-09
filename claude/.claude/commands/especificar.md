---
description: Definir — especificação antes do código (Figma, critérios de aceite, reuso de UI)
---

Fluxo sugerido: **DEFINIR** → `/tdd`

**Onde ficam as skills:** em `.claude/skills/<nome-da-pasta>/SKILL.md` (use o nome da pasta abaixo; não use caminho absoluto com usuário).

Leia e siga por completo, nesta ordem de importância:

1. **`criar-spec`** — desenvolvimento guiado por especificação (**sempre** delegue a parte de especificação ao subagente **requison**, como a skill exige; depois funda no `SPEC.md`)  
2. Se for detalhar critérios a partir do Figo: **`levanta-criterios-local`** — levantamento de critérios  
3. Para UI depois: **`frontend-ui-engineering`** — engenharia de UI  
4. Com frames Figo na spec: **`figma-implement-design`** — fidelidade ao layout (skill pode estar no plugin Figma/MCP do seu ambiente; procure `**/figma-implement-design/SKILL.md` no projeto ou na instalação global do Claude Code).

**Obrigatório:** invocar o **requison** para executar o trabalho de elicitação e redação alinhado ao template da skill **`criar-spec`** (não substituir pelo agente principal). Após o retorno, consolidar em `SPEC.md` e completar dados do repositório (comandos, pastas) se faltar.

**Quando a feature já está bem definida** (objetivo e escopo claros):

- O **requison** ainda assim produz o núcleo da spec; evite re-perguntar o óbvio no handoff.
- Com **link do Figma** e lista de funcionalidades ou telas: o fluxo MCP e o rigor de **`levanta-criterios-local`** entram como parte do que o requison aplica (e você valida no `SPEC.md`).

**Reuso de UI (obrigatório na spec):**

- Subseção **Reuso de componentes**: onde buscar no projeto e **reutilizar antes de criar**.

Gere a spec com as **seis áreas centrais** da skill **`criar-spec`**, mais **referência de design** quando houver Figo.

Salve como **`SPEC.md`** na raiz do projeto e alinhe com o usuário antes de `/tdd`.
