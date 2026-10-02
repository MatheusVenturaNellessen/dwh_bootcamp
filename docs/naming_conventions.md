# Convenções de Nomenclatura

Este documento descreve as convenções de nomenclatura utilizadas para schemas, tabelas, views, colunas e outros objetos do Data Warehouse.

## Sumário

1. [Princípios Gerais](#princípios-gerais)
2. [Convenções de Nomenclatura de Tabelas](#convenções-de-nomenclatura-de-tabelas)
    - [Regras da Camada Bronze](#regras-da-camada-bronze)
    - [Regras da Camada Silver](#regras-da-camada-silver)
    - [Regras da Camada Gold](#regras-da-camada-gold)
3. [Convenções de Nomenclatura de Colunas](#convenções-de-nomenclatura-de-colunas)
    - [Chaves Substitutas](#chaves-substitutas)
    - [Colunas Técnicas](#colunas-técnicas)
4. [Stored Procedures](#stored-procedures)

## Princípios Gerais

- **Convenção de nomenclatura:** utilizar `snake_case`, com letras minúsculas e underscores (`_`) para separar as palavras.
- **Idioma:** utilizar inglês para todos os nomes.
- **Palavras reservadas:** não utilizar palavras reservadas do SQL como nomes de objetos.

## Convenções de Nomenclatura de Tabelas

### Regras da Camada Bronze

- Todos os nomes devem começar com o nome do sistema de origem, e os nomes das tabelas devem corresponder aos nomes originais, sem renomeação.
- **Padrão:** `<source_system>_<entity>`
- `<source_system>`: nome do sistema de origem, como `crm` ou `erp`.
- `<entity>`: nome exato da tabela no sistema de origem.
- **Exemplo:** `crm_customer_info` → informações de clientes provenientes do sistema CRM.

### Regras da Camada Silver

- Todos os nomes devem começar com o nome do sistema de origem, e os nomes das tabelas devem corresponder aos nomes originais, sem renomeação.
- **Padrão:** `<source_system>_<entity>`
- `<source_system>`: nome do sistema de origem, como `crm` ou `erp`.
- `<entity>`: nome exato da tabela no sistema de origem.
- **Exemplo:** `crm_customer_info` → informações de clientes provenientes do sistema CRM.

### Regras da Camada Gold

- Todos os nomes devem ser significativos e alinhados ao negócio, começando pelo prefixo da categoria.
- **Padrão:** `<category>_<entity>`
- `<category>`: descreve a função da tabela, como `dim` para dimensão ou `fact` para tabela fato.
- `<entity>`: nome descritivo da tabela, alinhado ao domínio de negócio, como `customers`, `products` ou `sales`.

**Exemplos:**

- `dim_customers` → tabela dimensão contendo dados de clientes.
- `fact_sales` → tabela fato contendo transações de vendas.

#### Glossário de Prefixos de Categoria

| Padrão | Significado | Exemplo(s) |
|---|---|---|
| `dim_` | Tabela dimensão | `dim_customer`, `dim_product` |
| `fact_` | Tabela fato | `fact_sales` |

## Convenções de Nomenclatura de Colunas

### Chaves Substitutas

- Todas as chaves primárias das tabelas dimensão devem utilizar o sufixo `_key`.
- **Padrão:** `<table_name>_key`
- `<table_name>`: refere-se ao nome da tabela ou entidade à qual a chave pertence.
- `_key`: sufixo que indica que a coluna é uma chave substituta.
- **Exemplo:** `customer_key` → chave substituta da tabela `dim_customers`.

### Colunas Técnicas

- Todas as colunas técnicas devem começar com o prefixo `dwh_`, seguido por um nome descritivo que indique a finalidade da coluna.
- **Padrão:** `dwh_<column_name>`
- `dwh`: prefixo utilizado exclusivamente para metadados gerados pelo sistema.
- `<column_name>`: nome descritivo que indica a finalidade da coluna.
- **Exemplo:** `dwh_load_date` → coluna gerada pelo sistema utilizada para armazenar a data em que o registro foi carregado.

## Stored Procedures

- Todas as stored procedures utilizadas para carga de dados devem seguir o padrão:
- **Padrão:** `load_<layer>`
- `<layer>`: representa a camada que será carregada, como `bronze`, `silver` ou `gold`.

**Exemplos:**

- `load_bronze` → stored procedure responsável pela carga de dados na camada Bronze.
- `load_silver` → stored procedure responsável pela carga de dados na camada Silver.