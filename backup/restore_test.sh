#!/usr/bin/env bash
# Quarterly proof that backups restore: restores the latest dump into a scratch DB and counts rows.
set -euo pipefail
latest=$(docker compose exec -T backup sh -c 'ls -1t /backups/*.dump | head -1')
docker compose exec -T backup sh -c "sha256sum -c $latest.sha256"
docker compose exec -T db psql -U portal -c 'DROP DATABASE IF EXISTS restore_test;' -c 'CREATE DATABASE restore_test;'
docker compose exec -T backup sh -c "pg_restore -h db -U portal -d restore_test -j2 $latest"
docker compose exec -T db psql -U portal -d restore_test -c "SELECT relname, n_live_tup FROM pg_stat_user_tables ORDER BY 2 DESC LIMIT 10;"
docker compose exec -T db psql -U portal -c 'DROP DATABASE restore_test;'
echo "RESTORE TEST PASSED $(date +%F) $latest" | tee -a restore-tests.log
