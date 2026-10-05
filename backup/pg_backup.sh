#!/bin/sh
# Nightly pg_dump with checksum and 14-day rotation. Runs forever inside the backup sidecar.
set -eu
while true; do
  now=$(date +%F)
  f="/backups/portal-$now.dump"
  pg_dump -h db -U portal -Fc portal > "$f" && sha256sum "$f" > "$f.sha256" && echo "backup ok $f"
  find /backups -name 'portal-*.dump*' -mtime +14 -delete
  sleep 86400
done
