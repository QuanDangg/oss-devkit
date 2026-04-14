# Incremental Update Strategy

When `[backend-path]/.docs/_manifest.json` already exists, do NOT re-analyze the entire codebase.

## Steps

1. **Read the manifest** — get last-documented commit SHA
2. **Check if up to date** — if manifest commit == current HEAD, report "Already up to date (commit [SHA])" and stop
3. **Get changed files** — `git -C [repo-path] diff --name-only [old-commit]..HEAD`
4. **If diff fails** — fall back to `git log --oneline --name-only [old-commit]..HEAD` or ask the user
4. **Map changed files to docs** — see table below
5. **Re-analyze only affected sections** — read only changed source files, update corresponding docs
6. **Update manifest** — new commit SHA and timestamp
7. **Report what changed**

## File-to-Doc Mapping

| Changed file pattern | Update these docs |
|---|---|
| Models, schemas, entities | `models.md` |
| Migration config/tooling | `migrations.md` |
| Route/controller/handler files | `api-routes.md` |
| Service/use-case files | `services.md` |
| Auth/guard/policy files | `auth.md` |
| package.json, requirements.txt, Makefile | `dependencies.md`, `getting-started.md` |
| Config, docker, CI files | `overview.md`, `getting-started.md` |
| Entry points, bootstrap files | `overview.md` |

If >30% of source files changed, suggest a full re-analysis instead.

## Force Full Re-analysis

If user passes `--full`, ignore the manifest and run from scratch.
