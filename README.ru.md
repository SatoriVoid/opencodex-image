# OpenCodex Docker Image

[![Release OpenCodex image](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml/badge.svg)](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml)

[English](README.md) · Русский

Готовые multi-platform контейнерные образы для [OpenCodex](https://github.com/lidge-jun/opencodex). Сам OpenCodex не публикует официальный образ; этот репозиторий без изменений собирает upstream `Dockerfile` и публикует результат в GitHub Container Registry.

```text
ghcr.io/satorivoid/opencodex
```

Поддерживаются `linux/amd64` и `linux/arm64`.

## Быстрый старт с Docker Compose

Нужны Docker и плагин Docker Compose.

### 1. Клонируй репозиторий

```bash
git clone https://github.com/SatoriVoid/opencodex-image.git
cd opencodex-image
```

В репозитории уже есть готовый [`compose.yaml`](compose.yaml). Он использует `ghcr.io/satorivoid/opencodex:latest` и хранит состояние OpenCodex в host-директориях внутри `./data`.

### 2. Создай директории для состояния и API token

```bash
mkdir -p data/opencodex data/codex secrets

umask 077
openssl rand -hex 32 > secrets/opencodex_api_token
chmod 600 secrets/opencodex_api_token
```

### 3. Подготовь bind-mounted состояние

```bash
docker compose up init --abort-on-container-exit
```

Короткоживущий сервис `init` кладёт в состояние конфигурацию upstream-контейнера и выставляет права для OpenCodex. Это также даёт bind mounts работать с rootless Docker без `sudo` на хосте.

### 4. Инициализируй token

```bash
docker compose run --rm --no-deps -T hub \
  bun run docker/bootstrap-token.ts \
  < secrets/opencodex_api_token
```

Token сохраняется в `data/opencodex`. Сохрани `secrets/opencodex_api_token`: он нужен клиентам для аутентифицированного доступа. Оба пути исключены из Git.

### 5. Запусти OpenCodex

```bash
docker compose up -d hub
```

### 6. Проверь готовность

```bash
curl --fail --silent http://127.0.0.1:10100/healthz
curl --fail --silent http://127.0.0.1:10100/readyz
```

## Конфигурация

`compose.yaml` работает без `.env`. Создавай `.env` рядом с ним только если нужно изменить сетевые параметры или host paths:

```dotenv
# Network exposure
OPENCODEX_BIND_ADDRESS=127.0.0.1
OPENCODEX_PORT=10100

# Persistent state on the host
OPENCODEX_STATE_DIR=./data/opencodex
CODEX_STATE_DIR=./data/codex
```

| Переменная | По умолчанию | Назначение |
| --- | --- | --- |
| `OPENCODEX_BIND_ADDRESS` | `127.0.0.1` | Адрес хоста, на котором публикуется OpenCodex. |
| `OPENCODEX_PORT` | `10100` | Порт хоста, сопоставленный с портом OpenCodex `10100` внутри контейнера. |
| `OPENCODEX_STATE_DIR` | `./data/opencodex` | Конфигурация OpenCodex, API token и постоянное состояние. |
| `CODEX_STATE_DIR` | `./data/codex` | Состояние Codex, используемое OpenCodex. |

### Режимы доступа

**Только текущая машина или reverse proxy на том же хосте — рекомендуется**

Оставь значение по умолчанию:

```dotenv
OPENCODEX_BIND_ADDRESS=127.0.0.1
```

Если доступ нужен из другой сети, поставь перед сервисом аутентифицированный HTTPS reverse proxy.

**LAN или Tailscale**

Укажи только нужный адрес сетевого интерфейса:

```dotenv
OPENCODEX_BIND_ADDRESS=100.x.y.z
```

Сохрани API token и используй TLS или доверенную приватную сеть. Не открывай сервис на всех интерфейсах без явной необходимости и защиты.

## Теги образа

| Ссылка | Назначение |
| --- | --- |
| `:2.100.2` | Точный релиз OpenCodex |
| `:2.100` | Последний patch-релиз в ветке minor |
| `:2` | Последний minor-релиз в major-ветке |
| `:latest` | Последний опубликованный стабильный релиз; используется в `compose.yaml` |
| `@sha256:…` | Неизменяемая ссылка для развёртывания |

Чтобы зафиксировать версию или откатиться, замени `:latest` в `compose.yaml` на точный version tag или immutable digest из [релиза](https://github.com/SatoriVoid/opencodex-image/releases).

## Что проверяется

- npm-релиз сопоставляется с неизменяемыми upstream Git tag и commit.
- Образ собирается из upstream `Dockerfile` и проходит smoke-test до публикации.
- Каждый опубликованный образ получает SBOM и BuildKit provenance.
- Для каждого релиза публикуется GitHub provenance attestation.

## Проверка provenance

```bash
gh attestation verify \
  oci://ghcr.io/satorivoid/opencodex@sha256:<digest> \
  -R SatoriVoid/opencodex-image
```

## Upstream

- OpenCodex: https://github.com/lidge-jun/opencodex
- Лицензия upstream: MIT
