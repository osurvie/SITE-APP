# Apis

API REST minimaliste avec FastAPI — prête pour la production.

## Prérequis

- Python 3.14+
- pip

## Structure

```
application/
├── app/
│   ├── core/
│   │   └── config.py       # Settings (.env via pydantic-settings)
│   ├── routers/
│   │   ├── root.py         # GET /
│   │   └── health.py       # GET /health
│   ├── schemas/
│   │   └── common.py       # Response models Pydantic
│   └── main.py             # Entrypoint FastAPI
├── tests/
│   └── test_endpoints.py
├── .env.example
├── pyproject.toml          # Config pyproject (résolution du module `app` avec le pythonpath depuis la racine)
├── requirements.txt
└── requirements-dev.txt
```

## Installation

```bash
# 1. Se placer à la racine du projet
cd application/apis/01

# 2. (Optionnel) Créer un virtualenv
python -m venv .venv
source .venv/bin/activate        # Linux / macOS
.venv\Scripts\activate           # Windows (PowerShell)

# 3. Installer les dépendances
pip install -r requirements-dev.txt

# 4. Configurer l'environnement
cp .env.example .env
```

## Lancer le serveur

```bash
fastapi dev
# ou via uvicorn
uvicorn app.main:app --reload
```

L'API est disponible sur : /docs /redoc

> Le Swagger UI (`/docs`) est accessible uniquement si `DEBUG=true` dans le `.env`.

## Endpoints

| Method | Path      | Description  |
|--------|-----------|--------------|
| GET    | `/`       | Root         |
| GET    | `/health` | Health check |

## Lancer les tests

```bash
cd application/apis  # racine du projet
pytest               # lance tous les tests
pytest -v            # mode verbose (recommandé)
```