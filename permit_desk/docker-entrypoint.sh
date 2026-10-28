#!/bin/bash
set -e

until pg_isready -q -d "$DATABASE_URL"; do
  echo "waiting for postgres"
  sleep 1
done

if [ "$RUN_MIGRATIONS" = "true" ]; then
  bundle exec rake db:prepare
  bundle exec rake db:seed
else
  until bundle exec rake db:abort_if_pending_migrations >/dev/null 2>&1; do
    echo "waiting for schema"
    sleep 2
  done
fi

exec "$@"
