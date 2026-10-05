# portal-hosting-cicd

Containerized hosting and CI/CD for customer-facing web applications (self-service portal and
service-desk/ticketing) — Nginx with TLS in front, PostgreSQL behind, deployed through GitLab CI to
**staging** and **production** with database backups and restore tests built in.

```
GitLab CI: build → test → push image → deploy:staging → (manual) deploy:production
                                               │                    │
                                      docker compose pull/up   ssh + compose on prod host
```

* `docker-compose.yml` + `docker-compose.prod.yml` — app, worker, PostgreSQL, Nginx, backup sidecar
* `nginx/portal.conf` — TLS, HSTS, rate limiting, static caching, upstream health
* `.gitlab-ci.yml` — image build with cache, tests, tagged release, staged deploy with manual gate
* `backup/` — nightly `pg_dump` sidecar with checksum and 14-day rotation; `restore_test.sh` proves backups
* `monitoring/` — blackbox probe targets and Grafana alert for availability/response time
