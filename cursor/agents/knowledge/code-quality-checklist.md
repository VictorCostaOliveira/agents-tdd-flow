# Checklist de qualidade de código

## Tratamento de erros

### Anti-padrões a sinalizar

- **Exceção engolida:** `rescue` vazio ou que só loga
  ```ruby
  begin ... rescue; end            # falha silenciosa
  begin ... rescue => e; logger.info(e); end  # loga e esquece
  ```
- **Rescue largo demais:** `rescue Exception` ou `rescue StandardError` onde cabe um tipo específico
- **Vazamento de informação:** stack trace ou detalhe interno exposto ao usuário
- **Sem tratamento:** operação falível (IO, rede, parse) sem rescue na fronteira certa
- **Erro assíncrono:** promise rejeitada sem `.catch()`, job sem tratamento, sem error boundary

### Boas práticas a conferir

- [ ] Erros são tratados na fronteira apropriada
- [ ] Mensagens de erro são úteis ao usuário e sem detalhe interno
- [ ] Erros são logados com contexto suficiente para depurar
- [ ] Erros assíncronos são propagados ou tratados
- [ ] Há comportamento de fallback para erros recuperáveis
- [ ] Erros críticos disparam alerta ou monitoramento

### Perguntas a fazer
- "O que acontece quando esta operação falha?"
- "O chamador vai saber que algo deu errado?"
- "Há contexto suficiente para depurar este erro?"

---

## Performance e cache

### CPU

- **Operação cara no caminho quente:** compilar regex, parse de JSON ou criptografia dentro de loop
- **Bloqueio da thread principal:** IO síncrono ou cálculo pesado sem worker ou job
- **Recomputação:** o mesmo cálculo feito várias vezes
- **Memoização ausente:** função pura chamada repetidamente com a mesma entrada

### Banco e IO

- **N+1:** loop que faz uma query por item em vez de carregar em lote
  ```ruby
  # Ruim: N+1
  orders.each { |o| o.customer.name }
  # Bom: eager loading
  orders.includes(:customer).each { |o| o.customer.name }
  ```
- **Índice ausente:** query filtrando por coluna sem índice
- **Over-fetching:** `SELECT *` quando poucas colunas bastam
- **Sem paginação:** dataset inteiro carregado em memória

### Cache

- **Sem cache para operação cara:** chamada de API, query ou cálculo repetido
- **Cache sem TTL:** dado velho servido indefinidamente
- **Cache sem invalidação:** dado atualizado, cache intacto
- **Colisão de chave:** chave pouco específica
- **Dado de um usuário em cache global:** problema de segurança e privacidade

### Memória

- **Coleção sem limite:** array ou hash que cresce sem fim
- **Retenção de objeto grande:** referência que impede o GC
- **Concatenação de string em loop:** use `join` ou buffer
- **Arquivo grande carregado inteiro:** use streaming

### Perguntas a fazer
- "Qual é a complexidade desta operação?"
- "Como isto se comporta com 10× ou 100× mais dados?"
- "Este resultado é cacheável? Deveria ser?"
- "Dá para fazer em lote em vez de um por um?"

---

## Condições de borda

### Nulo e indefinido

- **Sem checagem de nil:** acesso a propriedade de objeto que pode ser nil
- **Confusão truthy/falsy:** `if value` quando `0` ou `""` são válidos (JavaScript)
- **Safe navigation em excesso:** `a&.b&.c&.d` escondendo problema estrutural
- **nil × undefined inconsistentes:** uso misto sem convenção

### Coleções vazias

- **Array vazio sem tratamento:** código assume que há itens
- **Objeto vazio:** iteração sobre hash vazio
- **Primeiro e último elemento:** `arr[0]` ou `arr.last` sem checar tamanho

### Limites numéricos

- **Divisão por zero:** sem checagem antes de dividir
- **Overflow:** número além do intervalo seguro
- **Comparação de ponto flutuante:** `==` em vez de tolerância
- **Valor negativo:** índice ou contagem que não deveria ser negativo
- **Off-by-one:** limites de loop, slice, paginação

### Strings

- **String vazia:** sem tratamento como borda
- **Só espaços:** passa em checagem truthy mas está vazia
- **String muito longa:** sem limite, estourando memória ou layout
- **Unicode:** emoji, texto RTL, caracteres combinados

### Padrões a sinalizar

```javascript
// Perigoso: sem checagem de nulo
const name = user.profile.name

// Perigoso: acesso sem checar tamanho
const first = items[0]

// Perigoso: divisão sem checagem
const avg = total / count

// Perigoso: truthy exclui valores válidos
if (value) { ... }  // falha para 0, "", false
```

### Perguntas a fazer
- "E se isto for nulo?"
- "E se esta coleção estiver vazia?"
- "Qual é o intervalo válido deste número?"
- "O que acontece nos limites (0, -1, MAX)?"
