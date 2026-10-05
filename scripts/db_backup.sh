#!/usr/bin/env bash
# Nightly: dump both databases, checksum, copy off-site, keep 14 days locally.
set -euo pipefail
TS=$(date +%F_%H%M); OUT=/backups/$TS; mkdir -p "$OUT"
pg_dump -h postgres -U "$POSTGRES_USER" -Fc "$POSTGRES_DB" > "$OUT/portal.dump"
mysqldump -h mariadb -u "$MARIADB_USER" -p"$MARIADB_PASSWORD" --single-transaction "$MARIADB_DATABASE" | gzip > "$OUT/ticketing.sql.gz"
( cd "$OUT" && sha256sum ./* > SHA256SUMS )
rsync -a "$OUT" "${OFFSITE_TARGET:-backup@dr-site:/backups/portal/}"
find /backups -maxdepth 1 -type d -mtime +14 -exec rm -rf {} +
echo "backup $TS ok"
