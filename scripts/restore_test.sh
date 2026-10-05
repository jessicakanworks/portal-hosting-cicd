#!/usr/bin/env bash
# Quarterly restore test: restore latest dump to a scratch DB and compare table counts.
set -euo pipefail
LATEST=$(ls -1d /backups/*/ | sort | tail -n1)
( cd "$LATEST" && sha256sum -c --quiet SHA256SUMS )
createdb -h postgres -U "$POSTGRES_USER" portal_restore_test
pg_restore -h postgres -U "$POSTGRES_USER" -d portal_restore_test -j2 "$LATEST/portal.dump"
LIVE=$(psql -h postgres -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atc "select count(*) from users")
TEST=$(psql -h postgres -U "$POSTGRES_USER" -d portal_restore_test -Atc "select count(*) from users")
dropdb -h postgres -U "$POSTGRES_USER" portal_restore_test
echo "restore test: live users=$LIVE restored users=$TEST ($LATEST)"
[[ "$TEST" -gt 0 ]]
