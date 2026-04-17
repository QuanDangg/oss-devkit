# oss-devkit

A Claude Code plugin that scans your codebase and generates lean `.docs/` knowledge files for future development. Documents **patterns and conventions** — not instance lists — so docs stay accurate as your project grows.

Supports frontend, backend, and full-stack projects. Includes incremental updates via git manifest tracking — only re-analyzes what changed since the last scan.

Also ships with an interactive BA requirement builder (Vietnamese) that generates detailed specs from survey files, DB schema, and source code.

## Install

```bash
claude plugin marketplace add QuanDangg/oss-devkit
claude plugin install oss-devkit
```

## License

[MIT](LICENSE)
