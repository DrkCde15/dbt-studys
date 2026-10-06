# dbt-estudos

Estudos de dbt + Postgres (via Podman).

## Pre-requisitos

- Podman
- `uv` (gerencia Python 3.12 + `.venv`)
- Container Postgres `dbt-postgres` rodando

## Credenciais (ver `.env`)

| Chave | Valor |
|---|---|
| Host | `localhost` |
| Porta | `5433` (a `5432` esta ocupada pelo `fraud-postgres`) |
| Banco | `dbt_estudos` |
| Usuario | `admin` |
| Senha | `admin123` |

String: `postgresql://admin:admin123@localhost:5433/dbt_estudos`

## Setup

```bash
# Postgres
podman start dbt-postgres || podman run -d --name dbt-postgres \
  -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin123 -e POSTGRES_DB=dbt_estudos \
  -p 5433:5432 -v dbt-pgdata:/var/lib/postgresql/data docker.io/library/postgres:16

# Python + dbt
uv venv --python 3.12 .venv
source .venv/bin/activate
uv pip install dbt-core dbt-postgres
```

## Uso

```bash
source .venv/bin/activate

# validar conexao
dbt debug --project-dir init_dbt

# seeds -> run -> test
dbt seed --project-dir init_dbt
dbt run --project-dir init_dbt
dbt test --project-dir init_dbt

# ou tudo junto a partir da pasta do projeto
cd init_dbt && dbt build
```

## SQL direto

```bash
podman exec dbt-postgres psql -U admin -d dbt_estudos -c "SELECT * FROM public.users_by_country;"
podman exec -i dbt-postgres psql -U admin -d dbt_estudos < ./query.sql
```

## Python

```python
import psycopg2
con = psycopg2.connect(host="localhost", port=5433, dbname="dbt_estudos",
                       user="admin", password="admin123")
```

## Estrutura

```
.
├── .env            # credenciais locais (ignorado pelo git)
├── init_dbt/       # projeto dbt (profile: init_dbt)
│   ├── seeds/
│   │   ├── users.csv    # 10 usuarios
│   │   └── orders.csv   # 16 pedidos
│   └── models/example/
│       ├── stg_users.sql        # select * from {{ ref('users') }}
│       ├── stg_orders.sql       # select * from {{ ref('orders') }}
│       ├── users_by_country.sql # agregado por pais
│       ├── users_by_month.sql   # agregado por mes (date_trunc)
│       ├── orders_by_user.sql   # join users+orders (n_orders, ltv)
│       └── schema.yml           # testes unique/not_null/relationships
└── .venv/          # ambiente Python (ignorado pelo git)
```

## Modelos e linhagem

```
users.csv ──> stg_users ──┬──> users_by_country
orders.csv ──> stg_orders ─┴──> orders_by_user
```

```
users.csv ──> stg_users ──┬──> users_by_country
                          ├──> users_by_month
orders.csv ──> stg_orders ─┴──> orders_by_user
```

Testes: `unique`/`not_null` em PKs, `relationships` em `stg_orders.user_id → stg_users.id`.

## Trilha de estudos (modulos)

### Modulo 0 — Ambiente ✅
Postgres no Podman, `.venv` Python 3.12, `dbt debug` verde.
Comandos: `podman run/start`, `uv venv`, `dbt debug`.

### Modulo 1 — Seeds e staging ✅
`seeds/users.csv`, `seeds/orders.csv` → `stg_users`, `stg_orders` com `{{ ref() }}`.
Comandos: `dbt seed`, `dbt run --select stg_*`.

### Modulo 2 — Marts e agregacoes ✅
`users_by_country`, `users_by_month` (`date_trunc`), `orders_by_user` (join + LTV).
Comandos: `dbt run`, `dbt show --select <model>`.

### Modulo 3 — Testes ⬜ (parcial)
Feito: `unique`, `not_null`, `relationships` no `schema.yml`.
Falta: `accepted_values` em `country`, teste singular (`assert_ltv_positive.sql`).
Comandos: `dbt test --select <model>`.

### Modulo 4 — Materializacoes ⬜
`{{ config(materialized='table') }}` em `orders_by_user`, `incremental` com `is_incremental()`.
Comandos: `dbt run`, comparar `view` vs `table` no psql (`\d+ public.orders_by_user`).

### Modulo 5 — Snapshots SCD2 ⬜
Rastrear mudanca de `email/country` com `dbt snapshot` (strategy `check`).
Comandos: `dbt snapshot`.

### Modulo 6 — Sources e freshness ⬜
Trocar um seed por `source()` + `freshness` e `dbt source freshness`.
Arquivos: `models/staging/sources.yml`.

### Modulo 7 — Macros, Jinja e packages ⬜
Macro propria (`cents_to_reais`), instalar `dbt_utils` via `packages.yml` (`surrogate_key`, `date_spine`).
Comandos: `dbt deps`, `dbt run`.

### Modulo 8 — Docs e linhagem ⬜
`descriptions` no `schema.yml`, `exposures`, `dbt docs generate && dbt docs serve`.

### Modulo 9 — Dev vs prod e orquestracao ⬜
Targets `dev/prod`, `dbt build --select state:modified`, agendar com Airflow.
