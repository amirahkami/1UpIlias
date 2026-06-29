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

if [[ -z "${DOCKER_HOST_GATEWAY_IP:-}" || "${DOCKER_HOST_GATEWAY_IP}" == "host-gateway" ]]; then
  gateway_ip="$(docker run --rm --add-host host.docker.internal:host-gateway alpine:3.20 sh -c "getent ahostsv4 host.docker.internal | awk 'NR==1{print \$1}'" 2>/dev/null || true)"
  if [[ -n "${gateway_ip}" ]]; then
    if grep -q '^DOCKER_HOST_GATEWAY_IP=' .env; then
      perl -0pi -e "s/^DOCKER_HOST_GATEWAY_IP=.*/DOCKER_HOST_GATEWAY_IP=${gateway_ip}/m" .env
    else
      printf '\nDOCKER_HOST_GATEWAY_IP=%s\n' "${gateway_ip}" >> .env
    fi
    export DOCKER_HOST_GATEWAY_IP="${gateway_ip}"
  fi
fi

if [[ ! -d src/.git ]]; then
  git clone "${ILIAS_SOURCE_URL}" ./src --single-branch -b "${ILIAS_SOURCE_REF}"
fi

./scripts/patch-ilias-oidc.sh

perl -pe 's/\$\{MARIADB_ROOT_PASSWORD\}/$ENV{MARIADB_ROOT_PASSWORD}/g; s/\$\{ILIAS_PORT\}/$ENV{ILIAS_PORT}/g' \
  conf/ilias.json.template > conf/ilias.json

docker compose up -d --build

./scripts/install-ilias.sh
