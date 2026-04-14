---
name: mockup-fullstack
description: >-
  Scans and documents a full-stack codebase by running both mockup-frontend and mockup-backend
  skills to generate lean .docs/ knowledge files for future development.
  Triggers when the user says "mockup project", "document fullstack", "map the whole project",
  "scan both frontend and backend", "document the codebase", "generate docs for the project",
  or provides both frontend and backend paths.
  Not for single-layer codebases (use mockup-frontend or mockup-backend directly).
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, Agent, AskUserQuestion
argument-hint: "[frontend-path] [backend-path] [--full]"
model: sonnet
effort: high
---

# Mockup Fullstack

Orchestrate documentation of a full-stack codebase by running both `mockup-frontend` and
`mockup-backend` skills in parallel, generating lean `.docs/` knowledge files for each layer.

## When to Use

- Scanning/mapping an entire full-stack project for future development
- Generating `.docs/` knowledge files for both frontend and backend layers
- User provides two paths (frontend + backend) or says "document the whole project"
- Incremental updates to both layers after code changes

## When NOT to Use

- **Frontend only** → use `mockup-frontend` instead
- **Backend only** → use `mockup-backend` instead
- **One-off code questions** → just read the files directly

## Instructions

### Phase 0 — Confirm Paths

1. Extract paths from arguments: `$ARGUMENTS` — first token is `[frontend-path]`, second is `[backend-path]`, `--full` flag means full rescan.
2. If either path is missing, use a single `AskUserQuestion`: "Which directories are the frontend and backend?"
3. Confirm both paths exist before proceeding.
4. Depth: default to **standard** unless the user explicitly passed `--overview` or `--deep` in `$ARGUMENTS`.

### Phase 0.5 — Pre-Check Both Layers (before spawning agents)

> **Do this before spawning any subagents.** Subagents do not receive `$ARGUMENTS`, so the early-exit logic must run here.

1. Collect git info. Use the **frontend path from Phase 0** (e.g. `./frontend`), NOT the project root directory:
   ```bash
   # Replace [frontend-path] with the actual frontend directory (e.g. ./frontend or /abs/path/frontend)
   git -C [frontend-path] rev-parse --show-toplevel 2>/dev/null   # → GIT_ROOT (may be parent of frontend-path)
   git -C [frontend-path] branch --show-current 2>/dev/null       # → GIT_BRANCH
   git -C [frontend-path] rev-parse --short HEAD 2>/dev/null      # → GIT_COMMIT
   ```
   If these return empty (exit non-zero), try the same commands with `[backend-path]`.
   If both fail, set `GIT_ROOT=null`, `GIT_BRANCH=null`, `GIT_COMMIT=null`.

2. Read `[frontend-path]/.docs/_manifest.json` (may not exist).
3. Read `[backend-path]/.docs/_manifest.json` (may not exist).
4. For each layer, determine its scan mode:
   - If `--full` was passed → **full scan**
   - Else if `GIT_COMMIT` is null → **cannot verify; treat as incremental** (do not stop)
   - Else if manifest exists AND `manifest.repo.branch == GIT_BRANCH` AND `manifest.repo.commit == GIT_COMMIT` → **skip** (already up to date)
   - Else if manifest exists but commit differs → **incremental**
   - Else no manifest → **full scan**
5. If **both** layers are **skip**: output `Both layers already up to date (branch: <GIT_BRANCH>, commit: <GIT_COMMIT>). Nothing to do.` and **STOP**.
6. Note which layers need scanning (frontend: skip/incremental/full, backend: skip/incremental/full) — pass this to the subagent prompts below.

### Phase 1 — Run Needed Layers in Parallel

Only spawn subagents for layers that are **not** skipped. Run them concurrently.

```
Agent(
  subagent_type: "mockup-frontend",
  prompt: "Run mockup-frontend on [frontend-path] at [depth] depth. Scan mode: [full|incremental — skip if already up to date was determined in caller]. Path: [frontend-path][, --full if full scan]"
)

Agent(
  subagent_type: "mockup-backend",
  prompt: "Run mockup-backend on [backend-path] at [depth] depth. Scan mode: [full|incremental — skip if already up to date was determined in caller]. Path: [backend-path][, --full if full scan]"
)
```

If a layer is **skip**, print `[Layer] already up to date — skipped.` instead of spawning an agent.

Wait for all spawned agents to complete before proceeding.

- If either subagent fails, report the error and ask the user whether to continue with the successful layer only or abort.

### Phase 2 — Cross-Layer Contract Review

After both scans complete, check for data-contract alignment:

1. Read `[frontend-path]/.docs/data-contracts.md` — if it does not exist, skip and note "frontend contracts not generated" in the Phase 4 summary.
2. Read `[backend-path]/.docs/data-contracts.md` — if it does not exist, skip and note "backend contracts not generated" in the Phase 4 summary.
3. Compare: flag any mismatches between frontend display constants and backend enum values.

### Phase 3 — CLAUDE.md Pointer

Ask user if they want pointers added to their `CLAUDE.md` for both layers:

```markdown
## Frontend Docs
See [frontend-path]/.docs/ for frontend architecture knowledge.

## Backend Docs
See [backend-path]/.docs/ for backend architecture knowledge.
```

### Phase 4 — Summary

Print a structured summary:

```
## Fullstack Mockup Complete

### Frontend ([frontend-path])
- Files generated: [list]
- Areas needing review: [list or "none"]

### Backend ([backend-path])
- Files generated: [list]
- Areas needing review: [list or "none"]

### Cross-Layer Contracts
- Mismatches: [list or "none found"]
- Skipped: [layer name if data-contracts.md was missing]

### Suggestions
- [follow-up recommendations]
```

## Git Restrictions

**NEVER run `git commit`, `git push`, `git add`.** Only READ from git. User commits when ready.
