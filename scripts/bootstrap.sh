#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  cp env.example .env
  echo "Created .env from env.example. Set MARIADB_ROOT_PASSWORD and run again." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

if [[ ! -d src/.git ]]; then
  git clone "${ILIAS_SOURCE_URL}" ./src --single-branch -b "${ILIAS_SOURCE_REF}"
fi

perl -pe 's/\$\{MARIADB_ROOT_PASSWORD\}/$ENV{MARIADB_ROOT_PASSWORD}/g; s/\$\{ILIAS_PORT\}/$ENV{ILIAS_PORT}/g' \
  conf/ilias.json.template > conf/ilias.json

docker compose up -d --build

./scripts/install-ilias.sh
