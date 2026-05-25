# fastapi-starter

## Structure

```
app/
├── core/
│   └── config.py       # Settings (pydantic-settings + .env)
├── routers/
│   ├── root.py         # GET /
│   └── health.py       # GET /health
├── schemas/
│   └── common.py       # Response models
└── main.py             # App entrypoint
tests/
└── test_endpoints.py
```

## Setup

```bash
cp .env.example .env
pip install -r requirements-dev.txt
```

## Run

```bash
uvicorn app.main:app --reload
```

## Test

```bash
pytest
```

## Endpoints

| Method | Path      | Description  |
|--------|-----------|--------------|
| GET    | `/`       | Root         |
| GET    | `/health` | Health check |

> Swagger UI available at `/docs` only when `DEBUG=true`.
