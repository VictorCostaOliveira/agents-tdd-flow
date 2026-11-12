# Checklist de segurança e confiabilidade

## Entrada e saída

- **XSS:** HTML injetado sem escape, `v-html` com dado do usuário, templates sem escape, `innerHTML`
- **Injeção:** SQL, NoSQL, comando de SO ou GraphQL montados por concatenação ou interpolação
- **SSRF:** URL controlada pelo usuário alcançando serviço interno sem lista permitida
- **Path traversal:** entrada do usuário em caminho de arquivo sem sanitização (`../`)
- **Prototype pollution:** merge de objeto inseguro em JavaScript (`Object.assign`, spread com dado do usuário)

## Autenticação e autorização

- Falta de checagem de tenant ou de dono em leitura e escrita
- Endpoint novo sem guarda de auth ou sem RBAC
- Confiança em papel, flag ou id vindo do cliente
- Controle de acesso quebrado (IDOR)
- Fixação de sessão ou gestão fraca de sessão

## JWT e tokens

- Confusão de algoritmo (aceitar `none` ou `HS256` quando se espera `RS256`)
- Segredo fraco ou fixo no código
- `exp` ausente ou sem validação
- Dado sensível no payload (JWT é base64, e não cifrado)
- `iss` ou `aud` sem validação

## Segredos e PII

- Chave, token ou credencial em código, config ou log
- Segredo no histórico do git ou em variável exposta ao cliente
- Log excessivo de PII ou de payload sensível
- Mensagem de erro sem mascaramento de dado

## Cadeia de suprimentos

- Dependência sem pin, permitindo atualização maliciosa
- Dependency confusion (colisão de nome de pacote privado)
- Import de fonte ou CDN sem checagem de integridade
- Dependência desatualizada com CVE conhecido

## CORS e headers

- CORS permissivo demais (`Access-Control-Allow-Origin: *` com credenciais)
- Header de segurança ausente (CSP, X-Frame-Options, X-Content-Type-Options)
- Header interno ou stack trace exposto

## Riscos em runtime

- Loop sem limite, recursão ou buffer grande em memória
- Chamada externa sem timeout, retry ou rate limit
- Operação bloqueante no caminho da request (IO síncrono em contexto assíncrono)
- Esgotamento de recurso (handles de arquivo, conexões, memória)
- ReDoS (expressão regular com backtracking catastrófico)

## Criptografia

- Algoritmo fraco (MD5, SHA1 para fins de segurança)
- IV ou salt fixo
- Cifra sem autenticação (modo ECB, sem HMAC)
- Chave curta

## Race conditions

Race conditions causam falhas intermitentes e brechas de segurança. Atenção especial a:

### Estado compartilhado
- Threads, goroutines ou tasks assíncronas acessando variável compartilhada sem sincronização
- Estado global ou singleton modificado concorrentemente
- Inicialização preguiçosa sem lock
- Coleção sem thread-safety em contexto concorrente

### Check-then-act (TOCTOU)
- `if existe then usa` sem operação atômica
- `if autorizado then executa` quando a autorização pode mudar no meio
- Checagem de existência de arquivo seguida de operação no arquivo
- Checagem de saldo seguida de débito (operações financeiras)
- Checagem de estoque seguida de pedido

### Concorrência no banco
- Lock otimista ausente (coluna `version`, `updated_at`)
- Lock pessimista ausente (`SELECT FOR UPDATE`)
- Read-modify-write sem isolamento de transação
- Incremento de contador sem operação atômica (`UPDATE SET count = count + 1`)
- Violação de unique em inserts concorrentes

### Sistemas distribuídos
- Lock distribuído ausente para recurso compartilhado
- Race na eleição de líder
- Race na invalidação de cache (leitura velha depois da escrita)
- Dependência de ordem de eventos sem sequenciamento
- Split-brain em operações de cluster

### Padrões a sinalizar
```
# Padrões perigosos:
if not exists(key):       # TOCTOU
    create(key)

value = get(key)          # read-modify-write
value += 1
set(key, value)

if user.balance >= amount:  # check-then-act
    user.balance -= amount
```

### Perguntas a fazer
- "O que acontece se duas requests chegarem aqui ao mesmo tempo?"
- "Esta operação é atômica ou pode ser interrompida?"
- "Que estado compartilhado este código acessa?"
- "Como isto se comporta sob alta concorrência?"

## Integridade de dados

- Transação ausente, escrita parcial ou estado inconsistente
- Validação fraca antes de persistir (coerção de tipo)
- Idempotência ausente em operação com retry
- Atualização perdida por modificação concorrente
