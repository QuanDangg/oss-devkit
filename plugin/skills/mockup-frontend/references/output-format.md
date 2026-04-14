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
[frontend-path]/.docs/
├── _manifest.json         # Commit tracking
├── _index.md              # Index with links to all docs
├── getting-started.md     # Install, configure, start
├── overview.md            # Architecture, structure, entry points
├── routing.md             # Route patterns + file locations
├── components.md          # Component patterns + organization
├── state.md               # State management approach
├── api-client.md          # API client patterns + data fetching
├── styling.md             # Styling approach, theming, tokens
├── patterns.md            # Conventions, hooks, testing
├── data-contracts.md      # Frontend enum/constant value→label maps, status display text, validation rules, backend value alignment
├── templates.md           # Downloadable template files (xlsx, csv, docx in public/assets): locations, download trigger, client-side export libs
└── dependencies.md        # Key packages + integrations
```

Skip files that don't apply. Merge small sections into `overview.md` if <10 lines.

## Conventions

- Reference files as `path/to/file.ext` — let Claude find lines when needed
- Use tables only for structured reference data (top framework deps, commands)
- **Describe patterns and locations, NEVER enumerate instances** — docs must stay accurate even after new components/routes/stores are added
- **Exception: static value maps ARE required** — frontend enum/constant value→label mappings, status display text, validation constraints must be captured in full in `data-contracts.md`. These are rendering contracts, not growing lists.
- Mark uncertain areas with `[?]`
- Do NOT copy code blocks — reference file locations instead
- Do NOT list individual components, pages, routes, stores, hooks, API calls, or any items that grow over time
- Target ~50-80 lines per file, max 100

## Index Format (`_index.md`)

```markdown
# Frontend Docs Index

> Auto-generated | YYYY-MM-DD | Branch: <branch> | Commit: <sha>
> (write "No git info" if branch/commit unavailable)

| File | Contents |
|---|---|
| [overview.md](overview.md) | one-line description |
| [routing.md](routing.md) | one-line description |
| ...                        | ...                  |
```

List every `.md` file generated in this run. One row per file.

## Manifest Format

```json
{
  "generated_at": "2026-04-05T10:30:00Z",
  "repo": {
    "path": "./frontend",
    "branch": "develop",
    "commit": "e4f5g6h",
    "commit_date": "2026-04-05T08:45:00Z"
  },
  "docs": {
    "overview.md": { "source_dirs": ["src/"], "commit": "e4f5g6h" }
  },
  "depth": "standard"
}
```

Use `source_dirs` (directories) instead of individual files to keep the manifest lean.
