---
name: mockup-backend
description: >-
  Scan and map a backend codebase, writing lean .docs/ knowledge files for future development.
  Triggers: "mockup backend", "map backend", "scan backend", "document backend structure".
  Not for frontend (use mockup-frontend) or external docs.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Agent, AskUserQuestion
argument-hint: "[backend-path] [--full]"
model: sonnet
effort: high
---

# Mockup Backend

Generate lean knowledge files from a backend codebase for future development.

## When to Use

- Scan/map a backend codebase for future development
- Generate `.docs/` knowledge files that persist across conversations
- Incremental updates after code changes

## When NOT to Use

- **Frontend codebases** → use `mockup-frontend` instead
- **One-off code questions** → just read the files directly

## HARD RULE: Describe Patterns, NEVER Enumerate Instances

**The generated docs must be TIMELESS. Adding a new model, route, command, or service should never make them stale.**

Describe HOW the codebase is organized and WHERE things live. Never list WHAT currently exists.

**Two exceptions — these ARE allowed:**

1. **Static Constraints:** Enum values, status/type codes, and constant value→label mappings are schema contracts, not growing lists. Capture them.
2. **Implementation Conventions:** Concrete patterns that every new module MUST follow — response shapes, endpoint naming conventions, permission naming patterns, CRUD lifecycle patterns, import/export flow patterns, delete strategy. These are **replication instructions**, not instance lists. A new developer (or AI) reading these should be able to build a new CRUD module that matches the existing codebase exactly.

### Forbidden Content (will make docs stale immediately)

- Lists/tables of individual models, entities, or their fields
- Lists/tables of individual API endpoints or routes
- Lists/tables of individual CLI commands or artisan/manage.py commands
- Lists/tables of individual migration files
- Lists/tables of individual service classes or methods
- Lists/tables of individual middleware or guards
- Lists/tables of individual background jobs or workers
- ANY enumeration of items that grows when developers add new code

### Allowed: Implementation Conventions (these are patterns, not instances)

Conventions answer "how do I build a new module that matches the existing codebase?" Examples of what to capture:

- CRUD endpoint naming convention (RESTful? action suffixes? what exact URL shape?)
- List response shape (exact DTO/wrapper class and its field structure)
- Permission naming convention (what pattern do permission strings follow?)
- Delete strategy (physical vs soft delete? how are child records handled?)
- Import/export flow (what base classes/pipes? streaming or direct download?)
- Uniqueness validation (DB constraint, app-level check endpoint, or both?)

These describe HOW to build, not WHAT exists. They stay valid when new modules are added.

### What to Write Instead

| Doc | GOOD (timeless) | BAD (goes stale) |
|---|---|---|
| `models.md` | "Prisma ORM. Models defined in `prisma/schema.prisma`. Key pattern: each model has `createdAt`/`updatedAt` timestamps. Relations use `@relation` with explicit foreign keys." | "Models: User, Post, Comment, Tag..." |
| `api-routes.md` | "Routes in `src/routes/`. Each file exports a router. Pattern: `[resource].routes.ts`. Middleware chain: auth → validate → handler. CRUD endpoint convention: [discovered pattern]. List response shape: [discovered DTO]." | "GET /api/users, POST /api/users, GET /api/posts..." |
| `migrations.md` | "Run: `npx prisma migrate dev`. Create: `npx prisma migrate dev --name [name]`. Files in `prisma/migrations/`." | "Migration 001_create_users, 002_add_posts..." |
| `services.md` | "Services in `src/services/`. Pattern: one file per business domain. Each exports a class with static methods." | "UserService.create(), UserService.findById()..." |
| `data-contracts.md` | "Order status: `1=pending, 2=processing, 3=shipped, 4=delivered, 5=cancelled`. Defined in `src/constants/order.ts`." | *(this IS good — static enum values are constraints, not instances)* |

### Line Targets

Target ~50-80 lines per doc. Max 100. Use `scripts/discover.sh` to save tokens.

## Git Restrictions

**NEVER run `git commit`, `git push`, `git add`.** Only READ from git. User commits when ready.

## Instructions

### PRE-CHECK — Run this before EVERYTHING else

> **This step has absolute priority. Complete it before reading any source files, before asking any questions, before proceeding to any Phase.**

1. Parse `$ARGUMENTS`: first token is the backend path. If no path, ask — but do nothing else until you have it.
2. If `--full` is in `$ARGUMENTS`, skip to **Phase 0** immediately (bypass this check).
3. Collect git info:
   ```bash
   git -C <backend-path> rev-parse --show-toplevel 2>/dev/null  # → GIT_ROOT
   git -C <GIT_ROOT> branch --show-current 2>/dev/null          # → GIT_BRANCH
   git -C <GIT_ROOT> rev-parse --short HEAD 2>/dev/null         # → GIT_COMMIT
   git -C <GIT_ROOT> log -1 --format=%cI HEAD 2>/dev/null       # → GIT_DATE
   ```
   If `--show-toplevel` returns empty, set all git fields to `null`.
4. Read `<backend-path>/.docs/_manifest.json`.
5. **EXIT CONDITION:** If the manifest exists AND `manifest.repo.branch == GIT_BRANCH` AND `manifest.repo.commit == GIT_COMMIT`:
   - Output **exactly**: `Already up to date (branch: <GIT_BRANCH>, commit: <GIT_COMMIT>). Nothing to do.`
   - **STOP. Call zero additional tools. Do not read any source files. Do not proceed to Phase 0 or any other phase. Your work is done.**
6. If the manifest exists but commit differs → proceed to Phase 0 with incremental update mode (see `references/incremental-update.md`).
7. If no manifest exists → proceed to Phase 0 with full scan mode.

---

### Phase 0 — Confirm Scope

1. *(Git info and manifest already collected in PRE-CHECK — reuse those values.)*
2. Ask depth: **overview** (fast) | **standard** (default) | **deep**
3. If not on the main branch, ask which branch is main (e.g. `main`, `master`, `develop`) and ask the user to switch (`git checkout <main-branch>`) before continuing — docs should reflect the canonical codebase state.

### Phase 1 — Reconnaissance

1. Read README if it exists (primary source for setup commands)
2. Run discovery script: `bash [skill-path]/scripts/discover.sh [backend-path]`
3. Detect stack from config files (package.json, requirements.txt, go.mod, etc.)
4. Map folder structure 2-3 levels deep

### Phase 2 — Targeted Analysis

#### Step 1: Reference Module Deep Dive

Before writing any docs, find **one complete CRUD module** — the one with the most endpoints (list, create, update, delete, import, export, check-name). Read its **entire lifecycle** end-to-end:

1. **Find it:** `Grep` for controllers with the most route decorators, or look for modules that have import/export + CRUD
2. **Read these files** for the chosen module:
   - Controller (all route handlers — endpoint paths, decorators, response types)
   - Service (business logic — soft delete cascade, uniqueness checks, pagination calls)
   - Repository (query patterns — how list queries are built, what response shape is returned)
   - DTOs (request/response shapes — pagination DTO, create/update DTOs, filter DTOs)
   - Entity (TypeORM decorators — soft delete, indexes, unique constraints, relations)
   - Migration (table creation — FK constraints, indexes, unique indexes)
   - Pipes (if any — import validation pipes like `BaseValidateImport`)

3. **Extract these conventions** (write them down — you'll use them in Step 2):
   - **Endpoint naming:** What suffix does POST create use? (`/create` vs RESTful?) What about check-name?
   - **Response shape:** What class wraps list responses? (`PaginationDto`? `CommonListResponse`? Something else?) Write the EXACT shape with field names.
   - **Permission naming:** What pattern do `@Permissions()` decorators use? (`API_GET_LIST_X`? `X_VIEW`?)
   - **Delete strategy:** Physical or soft delete? How are child records cascaded?
   - **Import flow:** What base class/pipe? What's the header/data row convention?
   - **Export flow:** Direct download or SSE status tracking? What decorators?
   - **Uniqueness:** DB-level UNIQUE index, app-level check, or both?

This is the most important step. Every convention you extract here prevents downstream specs from guessing wrong.

#### Step 2: Pattern docs per area

Read only 1-2 representative files per area to understand the pattern. Do NOT read every file.

| Doc file | What to capture (~line target) | NEVER include |
|---|---|---|
| `getting-started.md` | Install, env, dev server, required services, key scripts (~40) | Every available CLI/artisan/manage.py command |
| `overview.md` | Architecture pattern, annotated dir tree, entry points, config (~40) | Full file listings or module inventories |
| `api-routes.md` | Route organization, middleware chain, how to add a route. **MUST include from Reference Module:** exact CRUD endpoint naming convention (e.g. `POST /resource/create`), list response shape (exact DTO class + field structure), check-name endpoint pattern, pagination defaults (~50) | Table/list of individual endpoints |
| `models.md` | ORM, model patterns, key relationships, where models live. **MUST include:** soft-delete strategy (`@DeleteDateColumn` or equivalent), unique constraint pattern (DB-level vs app-level), parent-child cascade pattern (~40) | List of model names, fields, or columns |
| `migrations.md` | Tool, commands (run/create/rollback/status/seed), file location (~25) | List of migration files |
| `services.md` | Service pattern, where they live, business domain organization. **MUST include from Reference Module:** how list queries use pagination, how soft-delete cascade works in transactions, how uniqueness is checked (~40) | List of service classes or methods |
| `auth.md` | Auth strategy, role model, token flow, protected vs public. **MUST include:** permission enum naming convention with examples (e.g. `API_<ACTION>_<RESOURCE>`), where permissions are registered (enum file, JSON seed, migration), how frontend checks permissions (~35) | List of individual permissions or roles |
| `patterns.md` | Naming, error handling, testing approach, logging. **MUST include from Reference Module:** import/export flow pattern (base classes, SSE status, file download), validation pipe pattern (~40) | Exhaustive naming examples |
| `dependencies.md` | Top 5-8 framework-level deps (name \| purpose), external integrations (~25) | Every package from package.json/requirements.txt |
| `data-contracts.md` | **All** static enum/constant value→label mappings, status codes, type codes, flags. Where constants are defined. Pattern for declaring new ones (~40) | Dynamic/computed values, or anything that changes with data |
| `templates.md` | Export/report template files (xlsx, docx, pdf, html emails): where they live, naming pattern, what library generates them, how a new template is added (~30) | Individual template names or their column/field structure |

**`data-contracts.md` is critical** — it captures the numeric/string codes the frontend must interpret. Look for: enum declarations, `const` status/type objects, integer-to-label maps, boolean flags with semantic meaning, validation constraints (min/max lengths, regex patterns). These are the values that cause silent rendering bugs when undocumented.

Skip files that don't apply. Merge tiny sections into `overview.md`.

### Phase 3 — Generate Files

Write all files to `[backend-path]/.docs/`. See `references/output-format.md` for per-file structure and conventions.

**Always generate these two files — they are never optional:**

1. **`_index.md`** — markdown table linking to every doc file generated. See `references/output-format.md` for the format. Use git info collected in Phase 0 for the header; write `No git info` if unavailable.
2. **`_manifest.json`** — follow the manifest format exactly as defined in `references/output-format.md`. For `repo.path` use the `[backend-path]` argument as a relative path (e.g. `./backend`) — never the absolute `GIT_ROOT`. For branch/commit/date use `GIT_BRANCH`, `GIT_COMMIT`, `GIT_DATE` from Phase 0.

### Phase 4 — CLAUDE.md Pointer

Ask user if they want a pointer added to their `CLAUDE.md`.

### Phase 5 — Summary

Print: files generated, areas needing review, suggestions.
