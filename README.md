# Plano de Aula 2: DBT Core (Hands-On)

Este roteiro apresenta uma **linha do tempo** clara, para que o aluno acompanhe passo a passo: instalação, configuração, desenvolvimento de modelos (staging e core), testes e documentação no DBT, usando duas bases **(dev e prod)** no DuckDB.

---

## Linha do Tempo

1. **Instalação do Ambiente** (Python, VS Code)
2. **Instalação do DBT e DuckDB CLI**
3. **Criação do Projeto (dbt init)**
4. **Configuração de 2 Bancos (Dev e Prod)**
5. **Importação de Dados (Seeds)**
6. **Modelagem Staging**
7. **Modelagem Core**
8. **Testes e Documentação**

A seguir, cada passo detalhado.

---

## 1. Instalação do Ambiente (Windows + VS Code)

1. **Instalar Python** [Baixar o Python 3.11](https://www.python.org/downloads/release/python-31111/).
2. **Verificar** no terminal:
   ```bash
   python --version
   ```
3. **Instalar VS Code** em [code.visualstudio.com/download](https://code.visualstudio.com/download).
4. (Opcional) **Criar ambiente virtual** e ativar:
   ```bash
   python -m venv dbt
    ```
No Windows:
   ```bash
   .\dbt\Scripts\activate
   ```
No MAC:
   ```bash
   cd ~/dbt
   source bin/activate dbt
   ```

5. **Configurar o python no vscode** ctrl + shift + p
Validar se a versão do python que você está usando é a setada no VSCode

6. **Crie um repositório no GITHUB**
Vamos criar um repositório pra servir como nosso projeto final partindo do zero o nome dele será `dbthandson`.

7. **Clone esse repositório aqui**
Pra ficar o acesso aos arquivos que vamos trabalhar, clone esse repositório também para sua maquina, assim a movimentação dos modelos e csvs ficam mais simples.

8. **Sincronize o repositório `dbthandson` no seu VSCODE**
No icone de git, do vscode, coloque pra sincronizar conforme o vídeo.

 Videos dessa primeira etapa:
 DBT - Hands on - Parte 1 - https://youtu.be/4TqyFTXbzIc

---

## 2. Instalação do DBT CLI e DuckDB

1. **DBT CLI**:
   - Baixe os pacotes pré-compilados ou instale via pip:
     ```bash
     pip install dbt-core duckdb dbt-duckdb
     ```
   - (Opcional) Instale o **CLI** do DuckDB, por exemplo via no wndows `winget install duckdb` no MAC `brew install duckdb`.
   - 
2. **Verificar instalação**:
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

## 3. Criação repositório no Git e Projeto (dbt init)

1. **Repositório no Github**:
   - Se você não tem crie uma conta no GitHub
   - Vamos criar um repositório pra esse projeto de nome `dbtrescue`, e clonar ele para vscode.
  
2. **Criando o projeto dbt_olist**:
   Estando no diretorio do repositório crie o projeto dbt com o comando abaixo:
   ```bash
   dbt init dbt_olist
   ```
   - Isso gerará a subpasta `dbt_olist` com `dbt_project.yml`, `models/`, etc.
3. **Explicar** o `dbt_project.yml`: nome do projeto, versão, profile, etc.

Lembre se salvar tudo e fazer um commit e um push tanto local como online pra salvar tudo no seu repositorio do Github, lembre de fazer isso periodicamente pra não dar merda.

---

## 4. Configuração de 2 Bancos (Dev e Prod) no DuckDB

Vamos configurar o **`profiles.yml`** para ter dois ambientes: **dev** e **prod**. Eu substituo o que tem (no nosso caso pois estamos começando do zero) pelo conteúdo abaixo:duck

```yaml
# Em C:\Users\<User>\.dbt\profiles.yml (Windows) no Mac o profiles vai estar no home do usuário num diretorio oculto de nome .dbt
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
models:
  dbt_olist:
    staging:
      +schema: stg
      +materialized: table
    core:
      +schema: core
      +materialized: table

seeds:
  dbt_olist:
    +schema: raw
    +materialized: seed
```


- Agora é possível rodar:
  ```bash
  dbt run --target dev   # Usa duckdb_olist_dev.db e schema dev
  dbt run --target prod  # Usa duckdb_olist_prod.db e schema prod
  ```

### Ajuste de Schemas

No DBT, no dbt_profile.yml eu tenho como setar um complemento para o nome do schema assim como coloquei acima, sendo assim:
- seed fica: dev_raw
- staging fica: dev_stg
- core fica: dev_core
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
   {{ config(materialized='table') }}
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

## 9. Disponibilização dos Dados

- **Objetivo**: Consumir dados transformados.

1. **Conectar** `duckdb_olist_dev.db` (ou `duckdb_olist_prod.db`) em ferramentas de BI.
2. **Consultar**: `SELECT * FROM dev.core_orders;` etc.
3. **(Opcional)** Crie uma tabela "gold" (fact) agregando as principais métricas.

---

## Referências e Materiais de Apoio

- **Slides/PPT** da primeira aula: [Apresentação DBT (Aula 1)](https://docs.google.com/presentation/d/11oPh8UV6h-EJP8B92Vik3XO5rih4h82i2OZmVNzu9-o/edit?usp=sharing)
- **Documentação oficial DBT**: [https://docs.getdbt.com](https://docs.getdbt.com)
- **Kaggle: Olist Dataset**: [Link](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Documentação dbt-duckdb**: [https://github.com/getdbt/dbt-duckdb](https://github.com/getdbt/dbt-duckdb)
