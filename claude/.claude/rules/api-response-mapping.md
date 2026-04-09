# API — mapeamento de respostas (frontend)

O cliente consome uma API com **contrato acordado** (formato de envelope, nomes de campos, tipos). Ao mapear **JSON → estado/UI**:

## Faça

- Usar as **chaves e formas documentadas** (ex.: snake_case ou camel_case **consistente** no contrato) — **uma** convenção por endpoint, sem inventar variantes.
- Mapeamentos **diretos** do payload para o modelo da UI, com tipagem/`as` quando fizer sentido e alinhado ao contrato.
- Tratar **ausência** só onde o contrato ou o produto definem opcionalidade (`undefined`/`null`, fallback **explícito** de negócio).
- Tratativas especiais **só** quando necessário ou quando o utilizador pedir — não “por precaução” em todos os campos.

## Evite

- Fallbacks do tipo `data.foo ?? data.Foo` ou `snake ?? camel` quando o backend **não** expõe formatos alternativos nesse contrato.
- Camadas genéricas (`normalizeAnything`, `coalesceDeep`, `parseNumberSafe` em **cada** campo) sem requisito real — duplica lógica e mascara bugs de contrato.
- Suportar **vários formatos de backend** no mesmo mapa “caso um dia mude”; se o contrato mudar, **atualizar tipos e um mapa** na fronteira, não manter ramos mortos.

## Quando defesa faz sentido

- Campos **explicitamente** instáveis ou legados (documentados).
- Falhas **reais**: rede, 4xx/5xx, parse de input externo (querystring, CSV, upload).
- Validação na **borda** (entrada do utilizador), não em cada propriedade já tipada da resposta.

```typescript
// ✅ OK — alinhado ao contrato (ex.: snake_case)
const counts = meta.status_counts
  ? { active: meta.status_counts.active, inactive: meta.status_counts.inactive }
  : defaultCounts();

// ❌ Evitar — múltiplos formatos sem requisito
// const k = payload.kpis ?? payload.Kpis ?? payload.kpis_data;
```

**Resumo:** confie no contrato; defenda onde o risco é **real**, não em todo campo aninhado.
