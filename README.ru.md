# OpenCodex Docker Image

[![Release OpenCodex image](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml/badge.svg)](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml)

[English](README.md) · Русский

Готовые multi-architecture образы [OpenCodex](https://github.com/lidge-jun/opencodex) в GitHub Container Registry:

```text
ghcr.io/satorivoid/opencodex
```

Поддерживаются `linux/amd64` и `linux/arm64`.

Это packaging-образ, а не неизменённый upstream-образ: для каждого релиза берётся точный Git tag/commit OpenCodex, собирается его upstream `Dockerfile`, затем добавляется небольшой проверяемый runtime-слой. В образе есть официальные исполняемые файлы **Codex CLI** и **Claude Code**: dashboard может запускать интеграцию Codex app-server, а Claude Code уже доступен для будущего использования.

## Встроенные runtime

| Runtime | Зафиксированная версия | Зачем он нужен | Чего он не делает |
| --- | --- | --- | --- |
| OpenCodex | соответствует тегу образа | Hub/dashboard service | Не даёт OpenAI или Anthropic account. |
| Codex CLI | `0.167.1` | Даёт `codex` и `codex app-server` для dashboard integration. | Не аутентифицируется и не выполняет запросы без настройки пользователя. |
| Claude Code | `2.1.322` | Даёт CLI для будущего использования OpenCodex/Claude Code. | Не аутентифицируется, не настраивает provider и не делает Claude доступным без авторизации. |

Артефакты для каждой архитектуры берутся из официальных release-источников и сверяются с зафиксированными SHA-256 во время сборки. В образ не попадают API key, OAuth token или пользовательские credentials. Codex распространяется по Apache-2.0; Claude Code остаётся программой на условиях Anthropic.

Состояния OpenCodex, Codex и Claude Code разделены — их credentials и файлы состояния несовместимы:

- `/home/bun/.opencodex`
- `/home/bun/.codex`
- `/home/bun/.claude`

## Быстрый старт с Docker Compose

Нужны Docker и плагин Docker Compose.

### 1. Клонируй репозиторий

```bash
git clone https://github.com/SatoriVoid/opencodex-image.git
cd opencodex-image
```

[`compose.yaml`](compose.yaml) уже готов к запуску: `ghcr.io/satorivoid/opencodex:latest`, hardened non-root hub и видимые на хосте bind mounts в `./data`.

### 2. Создай директории состояния и API token

```bash
mkdir -p data/opencodex data/codex data/claude secrets

umask 077
openssl rand -hex 32 > secrets/opencodex_api_token
chmod 600 secrets/opencodex_api_token
```

### 3. Подготовь bind-mounted состояние

```bash
docker compose up init --abort-on-container-exit
```

Короткоживущий `init` создаёт конфигурацию OpenCodex и выставляет владельца для non-root runtime. Благодаря этому свежие bind mounts работают с rootless Docker без `sudo` на хосте.

### 4. Инициализируй API token OpenCodex

```bash
docker compose run --rm --no-deps -T hub \
  bun run docker/bootstrap-token.ts \
  < secrets/opencodex_api_token
```

Token сохраняется в `data/opencodex`. Сохрани `secrets/opencodex_api_token`: он нужен аутентифицированным клиентам. Оба пути исключены из Git.

### 5. Запусти и проверь hub

```bash
docker compose up -d hub
curl --fail --silent http://127.0.0.1:10100/healthz
curl --fail --silent http://127.0.0.1:10100/readyz
```

### 6. Проверь встроенные runtime от service user

```bash
docker compose exec hub codex --version
docker compose exec hub codex app-server --help
docker compose exec hub claude --version
```

Эти команды подтверждают наличие executables, но не авторизуют account ни у одного поставщика.

## Конфигурация

`compose.yaml` запускается без `.env`. Создавай `.env`, только чтобы изменить порт или пути к состоянию:

```dotenv
OPENCODEX_BIND_ADDRESS=127.0.0.1
OPENCODEX_PORT=10100
OPENCODEX_STATE_DIR=./data/opencodex
CODEX_STATE_DIR=./data/codex
CLAUDE_STATE_DIR=./data/claude
```

| Переменная | По умолчанию | Назначение |
| --- | --- | --- |
| `OPENCODEX_BIND_ADDRESS` | `127.0.0.1` | Адрес хоста, публикующий OpenCodex. |
| `OPENCODEX_PORT` | `10100` | Порт хоста. |
| `OPENCODEX_STATE_DIR` | `./data/opencodex` | Конфигурация OpenCodex, API token и состояние. |
| `CODEX_STATE_DIR` | `./data/codex` | Конфигурация Codex и авторизованное состояние клиента. |
| `CLAUDE_STATE_DIR` | `./data/claude` | Конфигурация Claude Code и авторизованное состояние клиента. |

Оставь loopback binding по умолчанию, если только намеренно не разворачиваешь аутентифицированный TLS/private-network frontend. Не публикуй management port `10101`.

## Теги и provenance

| Ссылка | Назначение |
| --- | --- |
| `:2.100.2` | Точный релиз OpenCodex с зафиксированными runtime выше. |
| `:2.100` | Последний patch-образ в minor-ветке OpenCodex. |
| `:2` | Последний образ в major-ветке OpenCodex. |
| `:latest` | Последний опубликованный stable-образ; используется в `compose.yaml`. |
| `@sha256:…` | Неизменяемая ссылка для развёртывания. |

Каждая публикация записывает в OCI labels packaging repository/source revision, upstream commit OpenCodex и версии bundled clients. Также публикуются SBOM, BuildKit provenance и GitHub provenance attestation.

```bash
gh attestation verify \
  oci://ghcr.io/satorivoid/opencodex@sha256:<digest> \
  -R SatoriVoid/opencodex-image
```

## Upstream и лицензии

- OpenCodex: [source](https://github.com/lidge-jun/opencodex) — MIT
- Codex CLI: [source and releases](https://github.com/openai/codex) — Apache-2.0
- Claude Code: [installation documentation](https://code.claude.com/docs/en/getting-started) — использование на условиях Anthropic
