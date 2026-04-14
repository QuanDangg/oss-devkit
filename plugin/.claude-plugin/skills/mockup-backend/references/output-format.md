# Output Format & Conventions

## File Structure

Each generated doc file:

```markdown
# [Title]

> Auto-generated | [YYYY-MM-DD] | Commit: [short SHA]

## Overview
[2-3 sentences]

## [Section]
[Lean content — patterns, references, commands]

## File Locations
[Key directories and what they contain]
```

## Output Directory

```
[backend-path]/.docs/
├── _manifest.json         # Commit tracking
├── _index.md              # Index with links to all docs
├── getting-started.md     # Install, configure, start
├── overview.md            # Architecture, structure, entry points
├── api-routes.md          # Route patterns + file locations
├── models.md              # Model patterns + relationships
├── migrations.md          # Migration commands only
├── services.md            # Service patterns + business domains
├── auth.md                # Auth strategy
├── patterns.md            # Conventions, naming, error handling, testing
├── data-contracts.md      # Enum/constant value→label maps, status codes, type codes, validation constraints
├── templates.md           # Export/report/email template files (xlsx, docx, pdf, html): locations, library, how to add
└── dependencies.md        # Key packages + integrations
```

Skip files that don't apply. Merge small sections into `overview.md` if <10 lines.

## Conventions

- Reference files as `path/to/file.ext` — let Claude find lines when needed
- Use tables only for structured reference data (top framework deps, commands)
- **Describe patterns and locations, NEVER enumerate instances** — docs must stay accurate even after new models/routes/services are added
- **Exception: static value maps ARE required** — enum values, status codes, type codes, and constant value→label mappings must be captured in full in `data-contracts.md`. These are schema contracts, not growing lists.
- Mark uncertain areas with `[?]`
- Do NOT copy code blocks — reference file locations instead
- Do NOT list individual models, routes, endpoints, services, commands, migrations, or any items that grow over time
- Target ~50-80 lines per file, max 100

## Index Format (`_index.md`)

```markdown
# Backend Docs Index

> Auto-generated | YYYY-MM-DD | Branch: <branch> | Commit: <sha>
> (write "No git info" if branch/commit unavailable)

| File | Contents |
|---|---|
| [overview.md](overview.md) | one-line description |
| [api-routes.md](api-routes.md) | one-line description |
| ...                            | ...                  |
```

List every `.md` file generated in this run. One row per file.

## Manifest Format

```json
{
  "generated_at": "2026-04-05T10:30:00Z",
  "repo": {
    "path": "./backend",
    "branch": "develop",
    "commit": "a1b2c3d",
    "commit_date": "2026-04-05T09:00:00Z"
  },
  "docs": {
    "overview.md": { "source_dirs": ["src/"], "commit": "a1b2c3d" }
  },
  "depth": "standard"
}
```

Use `source_dirs` (directories) instead of individual files to keep the manifest lean.
