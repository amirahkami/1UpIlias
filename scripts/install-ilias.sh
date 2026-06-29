#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "Missing .env. Run ./scripts/bootstrap.sh first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

echo "Waiting for MariaDB..."
until docker compose exec -T mariadb mariadb-admin ping -uroot -p"${MARIADB_ROOT_PASSWORD}" --silent >/dev/null 2>&1; do
  sleep 2
done

if docker compose exec -T web test -f /var/www/ilias/ilias.ini.php; then
  echo "ILIAS is already installed."
  exit 0
fi

docker compose exec -T web sh -lc 'cd /var/www/ilias && npm clean-install --omit=dev --ignore-scripts'
docker compose exec -T web sh -lc 'cd /var/www/ilias && composer install --no-dev'

docker compose exec -T web sh -lc '
  set -e
  cd /var/www/ilias
  if [ ! -d libs/bower/bower_components/mathjax ]; then
    wget -q https://github.com/mathjax/MathJax/archive/3.2.2.tar.gz
    tar -xzf 3.2.2.tar.gz
    mkdir -p libs/bower/bower_components
    rm -rf libs/bower/bower_components/mathjax
    mv MathJax-3.2.2 libs/bower/bower_components/mathjax
    rm 3.2.2.tar.gz
  fi
'

docker compose exec -T web sh -lc 'cd /var/www/ilias && php cli/setup.php install --yes /var/www/config/ilias.json'
docker compose exec -T web sh -lc 'mkdir -p /var/www/files/ilias/myilias/temp && chown -R www-data:www-data /var/www/files /var/www/logs'

echo "ILIAS is ready at http://localhost:${ILIAS_PORT:-28084}"
