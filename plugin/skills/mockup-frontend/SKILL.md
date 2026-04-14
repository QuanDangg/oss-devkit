---
name: mockup-frontend
description: >-
  Scan and map a frontend codebase, writing lean .docs/ knowledge files for future development.
  Triggers: "mockup frontend", "map frontend", "scan frontend", "document frontend structure".
  Not for backend (use mockup-backend) or external docs.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Agent, AskUserQuestion
argument-hint: "[frontend-path] [--full]"
model: sonnet
effort: high
---

# Mockup Frontend

Generate lean knowledge files from a frontend codebase for future development.

## When to Use

- Scan/map a frontend codebase for future development
- Generate `.docs/` knowledge files that persist across conversations
- Incremental updates after code changes

## When NOT to Use

- **Backend codebases** → use `mockup-backend` instead
- **One-off code questions** → just read the files directly

## HARD RULE: Describe Patterns, NEVER Enumerate Instances

**The generated docs must be TIMELESS. Adding a new component, route, store, or hook should never make them stale.**

Describe HOW the codebase is organized and WHERE things live. Never list WHAT currently exists.

**Exception — Static Constraints ARE allowed:** Enum values, status/type codes, and constant value→label mappings are schema contracts, not growing lists. Capture them. They define what the frontend must render and rarely change.

### Forbidden Content (will make docs stale immediately)

- Lists/tables of individual components or their props
- Lists/tables of individual pages or routes
- Lists/tables of individual stores, slices, or state keys
- Lists/tables of individual API calls or endpoints
- Lists/tables of individual hooks or composables
- Lists/tables of individual CSS classes or design tokens by name
- ANY enumeration of items that grows when developers add new code

### What to Write Instead

| Doc | GOOD (timeless) | BAD (goes stale) |
|---|---|---|
| `components.md` | "Components in `src/components/`, organized by feature. Pattern: each component folder has `index.tsx` + `styles.module.css`. Shared UI primitives in `src/components/ui/`." | "Button, Card, Modal, Header, Sidebar..." |
| `routing.md` | "Next.js app router. Pages in `src/app/`. Layouts nest via `layout.tsx`. Auth guard in `middleware.ts` protects all routes under `/dashboard`." | "/ → Home, /about → About, /dashboard → Dashboard..." |
| `state.md` | "Zustand stores in `src/stores/`. Pattern: one file per domain. Each exports a `use[Domain]Store` hook." | "useAuthStore, useCartStore, useUIStore..." |
| `api-client.md` | "Axios instance in `src/lib/api.ts`. Auth token injected via interceptor. Each feature has its own API file in `src/api/`." | "getUsers(), createPost(), deleteComment()..." |
| `data-contracts.md` | "Order status labels: `{1:'Pending', 2:'Processing', 3:'Shipped'}`. Defined in `src/constants/order.ts`, mirrored from backend." | *(this IS good — static value maps are contracts, not instance lists)* |

### Line Targets

Target ~50-80 lines per doc. Max 100. Use `scripts/discover.sh` to save tokens.

## Git Restrictions

**NEVER run `git commit`, `git push`, `git add`.** Only READ from git. User commits when ready.

## Instructions

### PRE-CHECK — Run this before EVERYTHING else

> **This step has absolute priority. Complete it before reading any source files, before asking any questions, before proceeding to any Phase.**

1. Parse `$ARGUMENTS`: first token is the frontend path. If no path, ask — but do nothing else until you have it.
2. If `--full` is in `$ARGUMENTS`, skip to **Phase 0** immediately (bypass this check).
3. Collect git info:
   ```bash
   git -C <frontend-path> rev-parse --show-toplevel 2>/dev/null  # → GIT_ROOT
   git -C <GIT_ROOT> branch --show-current 2>/dev/null           # → GIT_BRANCH
   git -C <GIT_ROOT> rev-parse --short HEAD 2>/dev/null          # → GIT_COMMIT
   git -C <GIT_ROOT> log -1 --format=%cI HEAD 2>/dev/null        # → GIT_DATE
   ```
   If `--show-toplevel` returns empty, set all git fields to `null`.
4. Read `<frontend-path>/.docs/_manifest.json`.
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
2. Run discovery script: `bash [skill-path]/scripts/discover.sh [frontend-path]`
3. Detect stack from config files (package.json, tsconfig, vite/next/nuxt config, etc.)
4. Map folder structure 2-3 levels deep

### Phase 2 — Targeted Analysis

Read only 1-2 representative files per area to understand the pattern. Do NOT read every file.

| Doc file | What to capture (~line target) | NEVER include |
|---|---|---|
| `getting-started.md` | Install, env, dev server + URL, build, key scripts, common issues (~40) | Every available npm script or CLI command |
| `overview.md` | Architecture pattern, annotated dir tree, entry points, build config (~40) | Full file listings or module inventories |
| `routing.md` | Routing approach, where pages live, guards, layouts, how to add a route (~30) | Table/list of individual pages or URLs |
| `components.md` | Organization pattern, directory locations + counts, composition patterns (~30) | List of component names or their props |
| `state.md` | Approach (Redux/Zustand/Pinia/etc), where stores live, global vs local (~25) | List of store names, slices, or state keys |
| `api-client.md` | Client setup, auth tokens, error handling, how to add an API call (~25) | List of individual API functions or endpoints |
| `styling.md` | Approach, theme/tokens location, responsive strategy, dark mode setup (~25) | List of CSS classes, token names, or color values |
| `patterns.md` | Naming, hooks/composables pattern, error handling, testing approach (~30) | List of individual hooks or composable names |
| `dependencies.md` | Top 5-8 framework-level deps (name \| purpose), external integrations (~25) | Every package from package.json |
| `data-contracts.md` | **All** frontend-side enum/constant value→label maps, status display text, type labels, validation rules (min/max, regex). Where frontend constants are defined. How they align with backend values. (~40) | Dynamic values, computed labels, or anything fetched at runtime |
| `templates.md` | Downloadable template files (xlsx, csv, docx in `public/` or `assets/`): where they live, naming pattern, what triggers the download. Client-side export libs if used. How to add a new downloadable template (~25) | Internal component template files (those belong in components.md) |

**`data-contracts.md` is critical** — it documents how the frontend translates backend numeric/string codes into human-readable text. Look for: status label maps, type display names, hardcoded option lists for dropdowns/selects, validation constraints (field length limits, allowed formats), i18n key patterns for status text. Mismatches between backend enum values and frontend display logic are a common source of bugs.

Skip files that don't apply. Merge tiny sections into `overview.md`.

### Phase 3 — Generate Files

Write all files to `[frontend-path]/.docs/`. See `references/output-format.md` for per-file structure and conventions.

**Always generate these two files — they are never optional:**

1. **`_index.md`** — markdown table linking to every doc file generated. See `references/output-format.md` for the format. Use git info collected in Phase 0 for the header; write `No git info` if unavailable.
2. **`_manifest.json`** — follow the manifest format exactly as defined in `references/output-format.md`. For `repo.path` use the `[frontend-path]` argument as a relative path (e.g. `./frontend`) — never the absolute `GIT_ROOT`. For branch/commit/date use `GIT_BRANCH`, `GIT_COMMIT`, `GIT_DATE` from Phase 0.

### Phase 4 — CLAUDE.md Pointer

Ask user if they want a pointer added to their `CLAUDE.md`.

### Phase 5 — Summary

Print: files generated, areas needing review, suggestions.
