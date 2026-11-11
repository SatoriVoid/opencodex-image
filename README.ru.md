# OpenCodex Docker Image

[![Release OpenCodex image](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml/badge.svg)](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml)

[English](README.md) · Русский

Готовые multi-platform контейнерные образы для [OpenCodex](https://github.com/lidge-jun/opencodex). Сам OpenCodex не публикует официальный образ; этот репозиторий без изменений собирает upstream `Dockerfile` и публикует результат в GitHub Container Registry.

```text
ghcr.io/satorivoid/opencodex
```

Поддерживаются `linux/amd64` и `linux/arm64`.

## Быстрый старт

1. Скопируй [`compose.example.yaml`](compose.example.yaml) в `compose.yaml`.
2. Подставь вместо `REPLACE_WITH_RELEASE_DIGEST` digest нужного [релиза](https://github.com/SatoriVoid/opencodex-image/releases).
3. Инициализируй service token и запусти сервис:

```bash
openssl rand -hex 32 | docker compose run --rm -T hub bun run docker/bootstrap-token.ts
docker compose up -d
```

Сохрани созданный token в конфигурации клиентов, которые обращаются к сервису. Не коммить его.

## Теги образа

| Ссылка | Назначение |
| --- | --- |
| `:2.100.2` | Точный релиз OpenCodex |
| `:2.100` | Последний patch-релиз в ветке minor |
| `:2` | Последний minor-релиз в major-ветке |
| `:latest` | Последний опубликованный стабильный релиз |
| `@sha256:…` | Неизменяемая ссылка для развёртывания |

Для production используй immutable digest из GitHub Release:

```yaml
image: ghcr.io/satorivoid/opencodex@sha256:<digest>
```

`latest` удобен для проверки, но не для фиксированного развёртывания.

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

## Откат

Выбери digest из предыдущего [релиза](https://github.com/SatoriVoid/opencodex-image/releases) и разверни его. На целевой машине пересобирать образ не нужно.

## Upstream

- OpenCodex: https://github.com/lidge-jun/opencodex
- Лицензия upstream: MIT
