# Commits — somente com permissão

- **Não** execute `git commit`, merges que concluam commit, nem finalize operações equivalentes (ex.: `git commit --amend`, `git rebase` que grave histórico) **sem o usuário pedir ou autorizar explicitamente**.
- **Não** assuma que “está pronto” autoriza commit — confirme ou espere instrução explícita (“pode commitar”, “faz o commit”, etc.).
- Pode preparar mensagens de commit em texto, `git status`, `git diff`, stage (`git add`) **se** o usuário pedir preparação — mas **não** grave o commit até autorização.
- Se o fluxo exigir commit (CI, hook), **pergunte** antes ou peça que o usuário execute o commit localmente.

**Resumo:** commit = só quando o usuário pedir ou autorizar.
