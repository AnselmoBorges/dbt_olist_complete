# Plano de Aula 2: DBT Core (Hands-On)

Este roteiro apresenta uma **linha do tempo** clara, para que o aluno acompanhe passo a passo: instalação, configuração, desenvolvimento de modelos (staging e core), testes e documentação no DBT, usando duas bases **(dev e prod)** no DuckDB.

---

## Linha do Tempo

1. **Instalação do Ambiente** (Python, VS Code)
2. **Instalação do DBT CLI e DuckDB**
3. **Criação do Projeto (dbt init)**
4. **Configuração de 2 Bancos (Dev e Prod)**
5. **Importação de Dados (Seeds)**
6. **Modelagem Staging**
7. **Modelagem Core**
8. **Testes e Documentação**
9. **Boas Práticas de Git**
10. **Disponibilização dos Dados** (BI, relatórios, etc.)
11. **Exercício Prático e Encerramento**

A seguir, cada passo detalhado.

---

## 1. Instalação do Ambiente (Windows + VS Code)

1. **Instalar Python** (>= 3.10 recomendado). Ao instalar, selecione "Add Python to PATH".
2. **Verificar** no terminal:
   ```bash
   python --version
   ```
3. **Instalar VS Code** em [code.visualstudio.com/download](https://code.visualstudio.com/download).
4. (Opcional) **Criar ambiente virtual** e ativar:
   ```bash
   python -m venv dbt .\dbt\Scripts\activate
   ```
5. **Instalar extensões** no VS Code: Python, Git Lens (opcional).

---

## 2. Instalação do DBT CLI e DuckDB

1. **DBT CLI**:
   - Baixe o pacote pré-compilado ou instale via pip:
     ```bash
     pip install dbt-core
     ```
2. **DuckDB**:
   - Instale a biblioteca Python:
     ```bash
     pip install duckdb dbt-duckdb
     ```
   - (Opcional) Instale o **CLI** do DuckDB, por exemplo via `winget install duckdb`.
3. **Verificar instalação**:
   ```bash
   dbt --version
   ```
   - Deve aparecer:
     ```
     Core: 1.x.x
     Plugins:
       - duckdb: 1.x.x
     ```

---

## 3. Criação do Projeto (dbt init)

1. **Repositório Starter**:
   - Crie uma pasta vazia, inicie um repositório Git se desejar.
2. **Executar**:
   ```bash
   dbt init dbt_olist
   ```
   - Isso gerará a subpasta `dbt_olist` com `dbt_project.yml`, `models/`, etc.
3. **Explicar** o `dbt_project.yml`: nome do projeto, versão, profile, etc.
4. **Commit** inicial (opcional):
   ```bash
   git add .
   git commit -m "Init dbt project"
   ```

---

## 4. Configuração de 2 Bancos (Dev e Prod) no DuckDB

Vamos configurar o **`profiles.yml`** para ter dois ambientes: **dev** e **prod**. Por exemplo:

```yaml
# Em C:\Users\<User>\.dbt\profiles.yml (Windows)
dbt_olist:
  target: dev  # Ambiente padrão
  outputs:
    dev:
      type: duckdb
      path: "./duckdb_olist_dev.db"  # Arquivo para o ambiente Dev
      schema: "dev"
      threads: 1

    prod:
      type: duckdb
      path: "./duckdb_olist_prod.db"  # Arquivo para o ambiente Prod
      schema: "prod"
      threads: 1
```

- No **`dbt_project.yml`**:
  ```yaml
  name: "dbt_olist"
  profile: "dbt_olist"
  config-version: 2
  # etc.
  ```
- Agora é possível rodar:
  ```bash
  dbt run --target dev   # Usa duckdb_olist_dev.db e schema dev
  dbt run --target prod  # Usa duckdb_olist_prod.db e schema prod
  ```

### Ajuste de Schemas

No DBT, podemos organizar a **camada staging** e **camada core** separando-as por schemas. Com DuckDB, vamos usar `schema: "dev"` ou `schema: "prod"` para separar ambientes. Caso queira
**diferentes schemas** dentro do mesmo ambiente, você pode definir as configs no `dbt_project.yml`, mas normalmente cada ambiente (dev/prod) já carrega seu schema.

---

## 5. Importação de Dados (Seeds)

1. **Baixar CSVs** do Olist ([Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)).
2. **Colocar** em `dbt_olist/seeds/`, renomeados para:
   - `orders.csv`, `customers.csv`, `order_items.csv`, etc.
3. **Executar**:
   ```bash
   dbt seed --target dev
   ```
   - Carrega os CSVs no `duckdb_olist_dev.db`, usando o schema `dev`.
4. **Verificar**:
   ```bash
   duckdb duckdb_olist_dev.db .tables .schema dev.orders
   ```

---

## 6. Modelagem Staging

1. **Criar** pasta `models/staging/`, com arquivos `.sql`:
   - `stg_orders.sql`, `stg_customers.sql`, etc.
2. **Exemplo** (stg\_orders.sql):
   ```sql
   {{ config(materialized='view') }}
   SELECT *
   FROM {{ ref('orders') }}
   ```
3. **Executar**:
   ```bash
   dbt run --target dev
   ```
   - Cria `dev.stg_orders` no `duckdb_olist_dev.db`.

---

## 7. Modelagem Core

1. **Criar** pasta `models/core/`, com arquivos `.sql`:
   - `core_orders.sql`, `core_order_items.sql`, etc.
2. **Exemplo** (core\_orders.sql), unindo staging:
   ```sql
   {{ config(materialized='view') }}

   WITH orders AS (
       SELECT * FROM {{ ref('stg_orders') }}
   ),
   payments AS (
       SELECT order_id, payment_type, payment_value
       FROM {{ ref('stg_order_payments') }}
   )

   SELECT
       o.order_id,
       o.customer_id,
       p.payment_type,
       p.payment_value
   FROM orders o
   LEFT JOIN payments p USING (order_id)
   ```
3. **Executar**:
   ```bash
   dbt run --target dev
   ```

---

## 8. Testes e Documentação

### 8.1 Testes

- Crie/edite um `schema.yml` para seeds e core.
- Exemplo de teste:
  ```yaml
  version: 2
  models:
    - name: core_orders
      columns:
        - name: order_id
          tests:
            - not_null
            - unique
  ```
- Rode:
  ```bash
  dbt test --target dev
  ```

### 8.2 Documentação

- Adicione descrições de tabelas/colunas no mesmo `schema.yml`.
- Gere:
  ```bash
  dbt docs generate --target dev
  dbt docs serve
  ```
- Abra no navegador e veja a lineage e o dicionário de dados.

---

## 9. Boas Práticas de Git

- **Branches**: crie branches para novas features.
- **Commits**: mensagens curtas e descritivas.
- **Pull Requests**: revise mudanças em cada branch.
- **Merge**: após aprovação, junte na branch principal.

---

## 10. Disponibilização dos Dados

- **Objetivo**: Consumir dados transformados.

1. **Conectar** `duckdb_olist_dev.db` (ou `duckdb_olist_prod.db`) em ferramentas de BI.
2. **Consultar**: `SELECT * FROM dev.core_orders;` etc.
3. **(Opcional)** Crie uma tabela "gold" (fact) agregando as principais métricas.

---

## 11. Exercício Prático e Encerramento

1.
   ## **Exemplo de roteiro**:
   1. Baixar CSV + seeds
   -
     2. Criar staging e core
   -
     3. Adicionar testes e docs
   -
     4. Rodar em `--target dev`
   -
     5. Revisar no DuckDB
   -
     6. Subir para Git e abrir PR
2. **Encerramento**:
   - Alinhar próximos passos: macros, exposures, snapshots.
   - Tirar dúvidas.

---

## Referências e Materiais de Apoio

- **Slides/PPT** da primeira aula: [Apresentação DBT (Aula 1)](https://docs.google.com/presentation/d/11oPh8UV6h-EJP8B92Vik3XO5rih4h82i2OZmVNzu9-o/edit?usp=sharing)
- **Documentação oficial DBT**: [https://docs.getdbt.com](https://docs.getdbt.com)
- **Kaggle: Olist Dataset**: [Link](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Documentação dbt-duckdb**: [https://github.com/getdbt/dbt-duckdb](https://github.com/getdbt/dbt-duckdb)

---

## Observações Finais

Seguindo esta **linha do tempo**, os alunos terão um pipeline do zero ao deploy em dois ambientes (dev e prod), aprendendo testes, documentação e práticas de versionamento. Ao final, estarão prontos para aprofundar em macros, snapshots e integrações de CI/CD.