# OpenCodex Image Factory

[![Release OpenCodex image](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml/badge.svg)](https://github.com/SatoriVoid/opencodex-image/actions/workflows/release.yml)

[English](README.md) · Русский

Минимальный воспроизводимый конвейер сборки контейнерных образов для [OpenCodex](https://github.com/lidge-jun/opencodex).

Он собирает OpenCodex из неизменяемого upstream Git tag и публикует multi-architecture образы в GitHub Container Registry. Этот репозиторий содержит только CI и упаковку: исходный код OpenCodex не форкается и не изменяется.

## Образы

```text
ghcr.io/satorivoid/opencodex
```

| Платформа | Поддержка |
| --- | --- |
| `linux/amd64` | Да |
| `linux/arm64` | Да |

## Гарантии

- npm-версия upstream сопоставляется с неизменяемым Git tag и commit SHA.
- Образ собирается из upstream `Dockerfile`.
- Каждый релиз проходит HTTP smoke-test до публикации.
- К OCI-образу прикрепляются BuildKit SBOM и provenance.
- GitHub Actions публикует provenance attestation.

## Теги и развёртывание

Workflow публикует теги версии, minor-версии, major-версии, `latest` и `upstream-<commit>`.

Для любого реального развёртывания используй immutable digest из соответствующего GitHub Release:

```yaml
image: ghcr.io/satorivoid/opencodex@sha256:<digest>
```

Не разворачивай `latest`.

## Сборка релиза

Открой **Actions → Release OpenCodex image → Run workflow**.

- Оставь `version` пустым, чтобы получить текущую стабильную npm-версию.
- Используй `force_rebuild` только для повторной сборки уже выпущенной upstream-версии.

Плановая проверка выполняется каждые шесть часов и пропускает версии, уже записанные как релизы.

## Быстрый старт с Docker Compose

Скопируй [`compose.example.yaml`](compose.example.yaml), подставь digest, затем до первого старта инициализируй локальный service token:

```bash
openssl rand -hex 32 | docker compose run --rm -T hub bun run docker/bootstrap-token.ts
docker compose up -d
```

Сохрани сгенерированный token в настройках клиентов, которые обращаются к сервису. Не коммить его в Git.

## Проверка provenance

```bash
gh attestation verify \
  oci://ghcr.io/satorivoid/opencodex@sha256:<digest> \
  -R SatoriVoid/opencodex-image
```

## Откат

Разверни digest из предыдущего GitHub Release. На целевом хосте пересобирать образ не требуется.

## Upstream

- OpenCodex: https://github.com/lidge-jun/opencodex
- Лицензия upstream: MIT
