---
name: pr-description-from-branch
description: Gera descrição de pull request em PT-BR (Contexto, Objetivo, features, testes da feature, como testar) a partir da branch atual, comparando com a base em origin e incorporando SPEC_* e spec/<feature> quando existirem. Usar quando o utilizador pedir descrição de PR, texto de merge request, corpo de MR ou resumo da feature com base na branch atual.
---

# Descrição de PR a partir da branch atual

## Objetivo

Produzir um **texto pronto para colar** no PR/MR, alinhado ao **diff real** contra `origin`, enriquecido por **docs de spec** quando existirem.

## Antes de escrever

1. **Branch atual:** `git branch --show-current` (ou equivalente).
2. **Base remota:** comparar com a branch de integração em `origin` (em geral `origin/main` ou `origin/master`; se o projeto usar `develop`, preferir essa). Se existir upstream configurado: `git rev-parse --abbrev-ref @{upstream}` ajuda. Se houver dúvida, usar a branch default do remoto: `git symbolic-ref refs/remotes/origin/HEAD` (ex.: `origin/main`).
3. **Atualizar refs (se fizer sentido):** `git fetch origin` para o diff refletir o remoto.
4. **Intervalo do PR:** usar diff tri-ponto quando for histórico de feature branch: `git diff origin/<base>...HEAD` e `git log --oneline origin/<base>..HEAD`. Estatísticas: `git diff --stat origin/<base>...HEAD`.

## Fontes obrigatórias (código)

- **Mudanças do PR:** paths e resumo a partir do `git diff` / `--stat` entre `<base>` e `HEAD`.
- **Commits:** títulos/mensagens em `git log origin/<base>..HEAD` para extrair intenção quando o diff for grande.

## Fontes opcionais (docs da feature)

Procurar **só se existirem** (não inventar paths):

| Padrão | Ação |
|--------|------|
| `SPEC_*` (ex.: na raiz ou em `docs/`) | Ler arquivos cujo nome case com a feature ou o ticket da branch. |
| `spec/<nome-da-feature>/` | Ler `.md` e outros relevantes dentro dessa pasta. O **slug** costuma ser **kebab-case** derivado do nome da feature ou da branch (`feature/foo-bar` → `foo-bar`). Se houver várias pastas em `spec/`, escolher a que melhor casa com a branch ou pedir ao utilizador **uma** confirmação curta. |

Se nada for encontrado, **Contexto** e **Objetivo** vêm do diff + commits + pedido do utilizador na conversa.

## Saída — estrutura fixa

Gerar Markdown nesta ordem e títulos:

### Contexto

- Por que a mudança existe (negócio/técnico), em 2–5 frases.
- Referência a ticket/issue se aparecer na branch, commits ou `SPEC_*`.

### Objetivo

- O que se pretende alcançar com o merge (mensurável ou verificável quando possível).

### Features implementadas

- Lista objetiva do que o PR entrega, **alinhada aos paths alterados** (componentes, endpoints, fluxos).
- Evitar bullet genérico; preferir itens rastreáveis ao diff (ex.: “filtro X na listagem Y”).

### Testes

- Indicar **se há testes** que cubram **esta feature** (não listar a suíte inteira do repo).
- Incluir **apenas** testes relacionados às mudanças do PR: arquivos `*.spec.*`, `*.test.*`, `*_spec.rb`, etc. que apareçam no diff ou que claramente targetam os módulos alterados.
- Se não houver testes no diff nem novos ficheiros de teste: declarar **explicitamente** (ex.: “Sem testes automatizados neste PR” ou “Testes existentes não alterados; cobertura X não incluída”).

### Como testar

- Passos manuais ou comando(s) para reproduzir (ex.: `pnpm vitest run caminho/do.spec.ts`, `bundle exec rspec caminho`).
- Pré-requisitos (env, seed, flag) se o diff indicar.

## Regras

- **Não** afirmar o que o diff não mostra; marcar suposições como tal.
- **Não** listar “todos os testes do projeto” — só os **ligados à feature** conforme acima.
- Manter tom **objetivo**; PT-BR; sem emojis obrigatórios.
- Se o repositório não tiver `origin` ou a base for ambígua: pedir **uma** escolha de branch base ao utilizador e seguir.

## Verificação rápida antes de entregar

- [ ] Base `origin/<branch>` explicitada na cabeça do texto (rodapé ou linha inicial) para rastreio.
- [ ] Secções preenchidas; “Testes” e “Como testar” honestos se vazios.
