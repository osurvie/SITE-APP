# Stack

## Prérequis:
- Installer [cloudflared](https://github.com/cloudflare/cloudflared)
- Installer python 3.14
- Installer docker (Ou Docker Desktop)
- Installer Ollama en Standalone


## Lancer l'api:
```sh
    cd apis/01
    pip install -r requirements-dev.txt
    pip install "fastapi[standard]"
    fastapi dev
```
## Lancer Ollama
```sh
    cd ollama

    # Via Docker Compose
    docker compose up -d
    docker exec -it ollama ollama pull llava:13b
    docker exec -it ollama ollama run llava:13b

    # Ou Standalone
    # https://docs.ollama.com/quickstart

```


## Lancer le tunnel cloudflare vers FastAPI
```sh
# → génère une URL temporaire valable le temps du process
# Possibilité de créer un compte Cloudflare pour bénéficier de plus
# Default api port: 8000
cloudflared tunnel --url http://localhost:8000
```
