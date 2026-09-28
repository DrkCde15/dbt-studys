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
| Porta | `5432` |
| Banco | `dbt_estudos` |
| Usuario | `admin` |
| Senha | `admin123` |

String: `postgresql://admin:admin123@localhost:5432/dbt_estudos`

## Setup

```bash
# Postgres
podman start dbt-postgres || podman run -d --name dbt-postgres \
  -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin123 -e POSTGRES_DB=dbt_estudos \
  -p 5432:5432 -v dbt-pgdata:/var/lib/postgresql/data docker.io/library/postgres:16

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
con = psycopg2.connect(host="localhost", port=5432, dbname="dbt_estudos",
                       user="admin", password="admin123")
```

## Estrutura

```
.
├── .env            # credenciais locais (ignorado pelo git)
├── init_dbt/       # projeto dbt (profile: init_dbt)
│   ├── seeds/users.csv
│   └── models/example/
│       ├── stg_users.sql
│       └── users_by_country.sql
└── .venv/          # ambiente Python (ignorado pelo git)
```
