---
name: criar-spec
description: Creates specifications before code. Phase 1 (Specify) is always delegated to the requison subagent — it elicits requirements and drafts content aligned to this skill’s template. Use when starting a project, feature, or large change without a spec. With Figma, run the MCP flow (below) before locking the spec. Suggested Cursor command /especificar.
---

# Criar spec (spec-driven development)

## Overview

Write a structured specification before writing any code. The spec is the shared source of truth between you and the human engineer — it defines what we're building, why, and how we'll know it's done. Code without a spec is guessing.

### Ruby / Rails & Vue

When the product is a Rails API plus a Vue SPA, the spec should name server-side (Ruby) vs client-side (Vue) responsibilities, background jobs, and API contracts explicitly—same rigor as for a Node/React stack.

## When to Use

- Starting a new project or feature
- Requirements are ambiguous or incomplete
- The change touches multiple files or modules
- You're about to make an architectural decision
- The task would take more than 30 minutes to implement
- The user shared a **Figma** link or the feature must **match a designed screen** — run the Figma flow in **Phase 1** before locking the spec

**When NOT to use:** Single-line fixes, typo corrections, or changes where requirements are unambiguous and self-contained.

## The Gated Workflow

Spec-driven development has four phases. Do not advance to the next phase until the current one is validated.

```
SPECIFY ──→ PLAN ──→ TASKS ──→ IMPLEMENT
   │          │        │          │
   ▼          ▼        ▼          ▼
 Human      Human    Human      Human
 reviews    reviews  reviews    reviews
```

### Phase 1: Specify

This skill defines **what** a good spec contains and **how** Phase 1 is gated; the **work of Phase 1 is always done by the `requison` subagent** — not by improvising the full spec in the main conversation. Same delegation pattern as **`cria-criterios`** → requison or **TDD** → figoso/testivos: the executing agent **orchestrates** and **consolidates**; requison **elicits and drafts** the core specification.

#### Mandatory: delegate Phase 1 to **requison**

1. **Invoke** the **`requison`** agent (e.g. Task tool with `subagent_type: "requison"`). **Do not** skip requison to write the spec alone “faster.”
2. **Handoff** must include everything requison needs: product/feature name, vision or goals, constraints, **Figma URL + node** when applicable (or explicit **no design**), list of functionalities/screens, stack (e.g. Rails + Vue), language/locale, and decisions the human already made.
3. Instruct requison to follow **this skill file** (template, six areas, ASSUMPTIONS, Figma section below) and **`agents/requison.md`**.
4. **If invocation fails**, retry before taking shortcuts.
5. **After** requison returns: **you** merge into **`SPEC.md`**, fill gaps from the **repository** where this skill requires local facts (real commands from `package.json`/Makefile, folder layout, style snippet), then request human review to close Phase 1.

Requison owns strategic questions, the **ASSUMPTIONS** block, functional/non-functional requirements, testable success criteria, per-functionality criteria when a list exists, edge cases, and **Open Questions** in this skill’s format.

#### When a Figma design is present

If there is a **Figma** URL, named frame, or **design-led** work, **requison** must run this flow **before** locking spec content — aligned with **`cria-criterios`**:

1. **Parse the link**
   - Pattern: `https://www.figma.com/design/:fileKey/:fileName?node-id=XXXX-YYYY` (and variants with `branch/` — use the branch key as `fileKey` when applicable).
   - **`fileKey`**: segment after `/design/` (or branch key if URL uses `branch/`).
   - **`nodeId`**: query `node-id` with hyphens replaced by colons (e.g. `4415-33144` → `4415:33144`).
   - For FigJam or other URL shapes, follow the Figma MCP server instructions in the workspace: use the documented tool for that asset type (e.g. FigJam → `get_figjam` when that is the source).

2. **Fetch context via MCP (server `plugin-figma-figma`)**
   - Read the tool descriptors under the workspace `mcps` folder for exact parameters before calling.
   - Call **`get_design_context`** with `fileKey`, `nodeId`, and optionally `clientLanguages` / `clientFrameworks` aligned to the project (e.g. `typescript`, `vue`).
   - Call **`get_screenshot`** with the same `fileKey` and `nodeId` for a visual anchor.
   - If the response is thin (e.g. section node, sparse structure), rely more on **`get_screenshot`** and, if needed, **`get_metadata`** to scope the node tree.

3. **Turn design into spec input** (requison’s responsibility under delegation)
   - List **screens, states, and flows** visible or implied (empty, loading, error, success).
   - Capture **copy**, **labels**, **table columns**, **status values** shown in the UI — be precise (same rigor as **`cria-criterios`**: enums, order of elements, actions next to content).
   - Note **constraints** the design implies (required fields, max lengths if annotated, breakpoints if multiple frames).
   - **Unresolved behavior** (what happens on submit, API errors) → **Open Questions**, not guesses.

4. **Merge into this skill’s spec template** (expected requison output)
   - **Objective** and **Success Criteria** should reflect what the design shows *and* what the product must achieve (design fidelity + business outcomes).
   - Add a short **Design reference** subsection if useful: Figma link, `fileKey`, `nodeId`, and date retrieved — so implementers can reopen the same node.
   - If the user asked for **objectives and acceptance criteria per functionality** (by screen or feature list), produce that block in the same style as **`cria-criterios`** (objectives ≥ 1 per item, testable criteria, Portuguese if the project/user uses Portuguese) **inside** the spec, then keep the rest of the six core areas (commands, structure, tests, boundaries) as usual.

5. **Still surface assumptions**
   - Design shows *what* the UI looks like, not always *backend rules* or *permissions*. After pulling Figma, list **ASSUMPTIONS** about data, auth, and edge cases; ask the human to confirm.

**When NOT to skip Figma:** The user pasted a Figma link or said “spec from this screen” — requison **always** runs the MCP pull first, unless the link is broken and the human agrees to proceed without design.

**Surface assumptions immediately.** Before consolidating spec content, requison lists what they're assuming:

```
ASSUMPTIONS I'M MAKING:
1. This is a web application (not native mobile)
2. Authentication uses session-based cookies (not JWT)
3. The database is PostgreSQL (based on existing Prisma schema or ActiveRecord models)
4. We're targeting modern browsers only (no IE11)
→ Correct me now or I'll proceed with these.
```

Don't silently fill in ambiguous requirements. The spec's entire purpose is to surface misunderstandings *before* code gets written — assumptions are the most dangerous form of misunderstanding.

**The `requison` output must cover these six core areas** (merged into the template below; the orchestrator may only complete what depends on repo inspection):

1. **Objective** — What are we building and why? Who is the user? What does success look like?

2. **Commands** — Full executable commands with flags, not just tool names.
   ```
   Build: npm run build
   Test: npm test -- --coverage
   Lint: npm run lint --fix
   Dev: npm run dev
   ```

3. **Project Structure** — Where source code lives, where tests go, where docs belong.
   ```
   src/           → Application source code
   src/components → React or Vue components
   src/lib        → Shared utilities
   tests/         → Unit and integration tests
   e2e/           → End-to-end tests
   docs/          → Documentation
   ```

4. **Code Style** — One real code snippet showing your style beats three paragraphs describing it. Include naming conventions, formatting rules, and examples of good output.

5. **Testing Strategy** — What framework, where tests live, coverage expectations, which test levels for which concerns.

6. **Boundaries** — Three-tier system:
   - **Always do:** Run tests before commits, follow naming conventions, validate inputs
   - **Ask first:** Database schema changes, adding dependencies, changing CI config
   - **Never do:** Commit secrets, edit vendor directories, remove failing tests without approval

**Spec template:**

```markdown
# Spec: [Project/Feature Name]

## Objective
[What we're building and why. User stories or acceptance criteria.]

## Design reference (optional — when spec is driven by Figma)
[Figma URL, fileKey, nodeId, retrieval date. Link back to frames/screens used.]

## Tech Stack
[Framework, language, key dependencies with versions]

## Commands
[Build, test, lint, dev — full commands]

## Project Structure
[Directory layout with descriptions]

## Code Style
[Example snippet + key conventions]

## Testing Strategy
[Framework, test locations, coverage requirements, test levels]

## Boundaries
- Always: [...]
- Ask first: [...]
- Never: [...]

## Success Criteria
[How we'll know this is done — specific, testable conditions]

## Open Questions
[Anything unresolved that needs human input]
```

**Reframe instructions as success criteria.** When receiving vague requirements, translate them into concrete conditions:

```
REQUIREMENT: "Make the dashboard faster"

REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s on 4G connection
- Initial data load completes in < 500ms
- No layout shift during load (CLS < 0.1)
→ Are these the right targets?
```

This lets you loop, retry, and problem-solve toward a clear goal rather than guessing what "faster" means.

### Phase 2: Plan

With the validated spec, generate a technical implementation plan:

1. Identify the major components and their dependencies
2. Determine the implementation order (what must be built first)
3. Note risks and mitigation strategies
4. Identify what can be built in parallel vs. what must be sequential
5. Define verification checkpoints between phases

The plan should be reviewable: the human should be able to read it and say "yes, that's the right approach" or "no, change X."

### Phase 3: Tasks

Break the plan into discrete, implementable tasks:

- Each task should be completable in a single focused session
- Each task has explicit acceptance criteria
- Each task includes a verification step (test, build, manual check)
- Tasks are ordered by dependency, not by perceived importance
- No task should require changing more than ~5 files

**Task template:**
```markdown
- [ ] Task: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm — test command, build, manual check]
  - Files: [Which files will be touched]
```

### Phase 4: Implement

Execute tasks one at a time following `implementacao-incremental` and `desenvolvimento-orientado-a-testes` skills. Use `context-engineering` to load the right spec sections and source files at each step rather than flooding the agent with the entire spec.

## Keeping the Spec Alive

The spec is a living document, not a one-time artifact:

- **Update when decisions change** — If you discover the data model needs to change, update the spec first, then implement.
- **Update when scope changes** — Features added or cut should be reflected in the spec.
- **Commit the spec** — The spec belongs in version control alongside the code.
- **Reference the spec in PRs** — Link back to the spec section that each PR implements.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "This is simple, I don't need a spec" | Simple tasks don't need *long* specs, but they still need acceptance criteria. A two-line spec is fine. |
| "I'll write the spec after I code it" | That's documentation, not specification. The spec's value is in forcing clarity *before* code. |
| "The spec will slow us down" | A 15-minute spec prevents hours of rework. Waterfall in 15 minutes beats debugging in 15 hours. |
| "Requirements will change anyway" | That's why the spec is a living document. An outdated spec is still better than no spec. |
| "The user knows what they want" | Even clear requests have implicit assumptions. The spec surfaces those assumptions. |

## Red Flags

- **Skipping `requison` in Phase 1** and writing the spec entirely in the main agent (viola esta skill)
- Starting to write code without any written requirements
- Asking "should I just start building?" before clarifying what "done" means
- Implementing features not mentioned in any spec or task list
- Making architectural decisions without documenting them
- Skipping the spec because "it's obvious what to build"

## Verification

Before proceeding to implementation, confirm:

- [ ] **Phase 1 was executed via `requison`** (delegação obrigatória; resultado fundido em `SPEC.md` ou equivalente)
- [ ] The spec covers all six core areas
- [ ] The human has reviewed and approved the spec
- [ ] Success criteria are specific and testable
- [ ] Boundaries (Always/Ask First/Never) are defined
- [ ] The spec is saved to a file in the repository
- [ ] If Figma was the source: design was pulled via MCP (`get_design_context` + `get_screenshot`), and **Design reference** (or equivalent) points to the correct `fileKey` / `nodeId`
