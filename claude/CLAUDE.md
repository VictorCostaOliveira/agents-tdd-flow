# Projeto Rails + Vue

Stack: API Rails (RSpec) e front Vue 3 (Vitest). Especificação antes do código quando o pedido for vago; testes antes da implementação.

## Regras

Ficam em `.claude/rules/`: commit só com autorização, documentação mínima, mapeamento de API pelo contrato, padrões de Rails e testes. Valem em todo o repositório.

## Fluxo de uma feature

1. `/criar-spec`: o **requison** levanta requisitos e critérios de aceite; a spec vai para `SPEC.md`. Sistema ou integração nova: `/spec-arquitetura`.
2. `/implementa-spec`: plano com cobertura da SPEC, TDD um cenário por vez, auditoria adversarial e revisão no fim. Tela a partir do Figma: `/tdd`, com **figoso** → **testivos** → **devoso** → **refoso** → **avaliason**, um artefato por etapa e aprovação entre elas.
3. **verifier** confirma que o que foi declarado pronto funciona; **security-auditor** revisa o diff.
4. `/pr-desc` escreve a descrição do PR a partir da branch.

Decisão de arquitetura: **arquiteto**, sempre com mais de uma opção.

## Comandos

```
Testes back:  bundle exec rspec
Testes front: pnpm vitest run
Lint:         bundle exec rubocop
```

Ajuste os comandos, as pastas e o nome das libs internas ao seu projeto.
