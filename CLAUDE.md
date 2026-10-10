# Claude handoff — Xantara POS

Before changing this repository, read `C:\Dev\Xantara-POS-project-knowledge.md`.
It is the shared, authoritative handoff for the Flutter POS, Django backend, and
Next.js admin frontend. Later numbered entries supersede older status text when
the document records an evolution of the implementation.

After any meaningful code, schema, configuration, API, security, setup,
deployment, or architecture change, update that shared knowledge file in the same
task. Keep it factual and include verification results. Code and tests remain the
authority if documentation is stale.

## Workspace map

- Flutter POS: `C:\Dev\Xantara-POS`
- Django/MySQL API: `C:\Dev\xantara-web-backend`
- Next.js admin: `C:\Dev\xantara-web-frontend`
- Shared knowledge: `C:\Dev\Xantara-POS-project-knowledge.md`

## Local services

- Flutter web preview: `http://127.0.0.1:8086` — this is the canonical and fixed
  local Xantara POS port. `scripts\start-local-preview.ps1` builds and starts it.
- Admin frontend: `http://127.0.0.1:3000`
- Django API: `http://127.0.0.1:8000`
- Local backend database: MySQL database `xantara_pos_db`
- The 8086 preview proxies `/api/` and `/media/` to Django on port 8000.

## Current cross-application behavior

- The Django/MySQL backend is the shared catalog, staff-directory, branch, and
  store-settings source used by the admin frontend and Flutter cloud sync.
- Flutter remains offline first with Drift/SQLite for sales, invoice numbering,
  device staff credentials, stock operations, audit events, and durable queues.
- Flutter uploads its durable sync queue before atomically downloading the
  authenticated `MAIN` catalog from MySQL.
- Web staff records and Flutter local login records are intentionally separate.
- Fresh web deployments use the one-time `/setup` flow: company, main branch,
  first administrator. Existing installations are marked complete by migration.
- The local installation is `Xantara POS`, business ID `xantara`, and setup is
  already complete. Port 8086 must remain the Flutter preview port.

## Common commands

```powershell
.\.tools\flutter\bin\flutter.bat analyze
.\.tools\flutter\bin\flutter.bat test
.\scripts\start-local-preview.ps1
```

Tests exist and are required for material behavior changes. Preserve invoice
immutability, integer money, branch-scoped inventory, atomic business operations,
explicit authorization, offline operation, and safe handling of secrets.
