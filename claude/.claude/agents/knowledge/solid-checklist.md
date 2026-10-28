# Checklist SOLID e cheiros de código

## SRP (responsabilidade única)

- Arquivo com preocupações sem relação (HTTP + banco + regra de domínio no mesmo lugar)
- Classe ou módulo grande com baixa coesão ou vários motivos para mudar
- Função que orquestra muitos passos sem relação
- Objeto-deus que sabe demais sobre o sistema
- **Pergunte:** "Qual é o único motivo para este módulo mudar?"

## OCP (aberto/fechado)

- Comportamento novo exige editar vários `switch`/`if`
- Crescimento de feature exige mexer na lógica central em vez de estender
- Sem ponto de variação (strategy, hook, plugin)
- **Pergunte:** "Consigo adicionar uma variante sem tocar no código existente?"

## LSP (substituição de Liskov)

- Subclasse checa tipo concreto ou lança exceção em método da base
- Método sobrescrito enfraquece pré-condições ou endurece pós-condições
- Subclasse ignora ou anula comportamento do pai
- **Pergunte:** "Consigo substituir qualquer subclasse sem o chamador perceber?"

## ISP (segregação de interface)

- Interface com muitos métodos, a maioria sem uso pelos implementadores
- Chamador depende de interface larga para uma necessidade estreita
- Implementações vazias ou stub de métodos da interface
- **Pergunte:** "Todos os implementadores usam todos os métodos?"

## DIP (inversão de dependência)

- Lógica de alto nível depende de IO, storage ou rede concretos
- Implementação fixa no código em vez de abstração ou injeção
- Cadeia de imports acoplando regra de negócio a infraestrutura
- **Pergunte:** "Consigo trocar a implementação sem mudar a regra de negócio?"

---

## Cheiros comuns (além de SOLID)

| Cheiro | Sinais |
|--------|--------|
| **Método longo** | Mais de 30 linhas, vários níveis de aninhamento |
| **Inveja de feature** | Método usa mais dados de outra classe que da própria |
| **Grupo de dados** | Mesmo conjunto de parâmetros passado junto repetidamente |
| **Obsessão por primitivos** | String e número no lugar de tipos de domínio |
| **Cirurgia com espingarda** | Uma mudança exige editar muitos arquivos |
| **Mudança divergente** | Um arquivo muda por muitos motivos sem relação |
| **Código morto** | Código inalcançável ou nunca chamado |
| **Generalidade especulativa** | Abstração para necessidade futura hipotética |
| **Números e strings mágicos** | Valor fixo sem constante nomeada |

---

## Heurísticas de refatoração

1. **Separe por responsabilidade, e não por tamanho.** Arquivo pequeno também viola SRP.
2. **Abstraia só quando precisar.** Espere o segundo caso de uso.
3. **Refatore em passos pequenos.** Isole o comportamento antes de mover.
4. **Preserve o comportamento primeiro.** Testes antes de reestruturar.
5. **Nomeie pela intenção.** Nome difícil costuma indicar abstração errada.
6. **Prefira composição a herança.** Herança acopla forte.
7. **Torne estados inválidos irrepresentáveis.** Use tipos para impor invariantes.
