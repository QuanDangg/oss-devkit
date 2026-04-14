#!/usr/bin/env bash
# Usage: bash discover.sh <frontend-path>
# Outputs a lean summary of a frontend codebase: structure, counts, file locations.
# Designed to be run by Claude to avoid reading hundreds of files individually.

set -euo pipefail
ROOT="${1:-.}"

echo "=== FOLDER STRUCTURE (3 levels) ==="
find "$ROOT" -maxdepth 3 -type d \
  ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' \
  ! -path '*/build/*' ! -path '*/.next/*' ! -path '*/.nuxt/*' \
  ! -path '*/.svelte-kit/*' ! -path '*/.cache/*' | sort

echo ""
echo "=== CONFIG FILES ==="
for f in .env.example .env.sample package.json tsconfig.json vite.config.ts vite.config.js \
  next.config.ts next.config.js next.config.mjs nuxt.config.ts angular.json \
  tailwind.config.ts tailwind.config.js postcss.config.js postcss.config.mjs \
  svelte.config.js astro.config.mjs; do
  [ -f "$ROOT/$f" ] && echo "$ROOT/$f"
done

echo ""
echo "=== PAGE/ROUTE FILES ==="
# Next.js app router
cnt=$(find "$ROOT/src/app" "$ROOT/app" -name 'page.tsx' -o -name 'page.jsx' -o -name 'page.ts' 2>/dev/null | wc -l | tr -d ' ')
[ "$cnt" -gt 0 ] && echo "Next.js app router pages: $cnt"
# Next.js pages router
cnt=$(find "$ROOT/src/pages" "$ROOT/pages" \( -name '*.tsx' -o -name '*.jsx' \) ! -name '_*' 2>/dev/null | wc -l | tr -d ' ')
[ "$cnt" -gt 0 ] && echo "Next.js pages router files: $cnt"
# Vue/Nuxt
cnt=$(find "$ROOT/src/views" "$ROOT/src/pages" "$ROOT/pages" -name '*.vue' 2>/dev/null | wc -l | tr -d ' ')
[ "$cnt" -gt 0 ] && echo "Vue page/view files: $cnt"
# Angular
cnt=$(find "$ROOT/src/app" -name '*routing*' -o -name '*routes*' 2>/dev/null | wc -l | tr -d ' ')
[ "$cnt" -gt 0 ] && echo "Angular routing files: $cnt"
# Generic route config
grep -rl 'createBrowserRouter\|createRouter\|Routes\|RouteObject' "$ROOT/src" --include='*.ts' --include='*.tsx' --include='*.js' 2>/dev/null | head -5

echo ""
echo "=== COMPONENT DIRECTORIES ==="
for dir in $(find "$ROOT/src" -type d \( -name 'components' -o -name 'ui' -o -name 'common' -o -name 'shared' -o -name 'widgets' \) 2>/dev/null); do
  cnt=$(find "$dir" \( -name '*.tsx' -o -name '*.jsx' -o -name '*.vue' -o -name '*.svelte' \) 2>/dev/null | wc -l | tr -d ' ')
  echo "$dir ($cnt files)"
done

echo ""
echo "=== CUSTOM HOOKS/COMPOSABLES ==="
cnt=$(find "$ROOT/src" -name 'use*.ts' -o -name 'use*.tsx' -o -name 'use*.js' 2>/dev/null | wc -l | tr -d ' ')
echo "Custom hooks: $cnt"
cnt=$(find "$ROOT/src" -path '*/composables/*' -name '*.ts' 2>/dev/null | wc -l | tr -d ' ')
[ "$cnt" -gt 0 ] && echo "Vue composables: $cnt"

echo ""
echo "=== STATE MANAGEMENT ==="
find "$ROOT/src" \( -name '*store*' -o -name '*slice*' -o -name '*reducer*' -o -name '*context*' \) ! -path '*/node_modules/*' 2>/dev/null | head -10

echo ""
echo "=== API CLIENT FILES ==="
find "$ROOT/src" \( -name '*api*' -o -name '*client*' -o -name '*service*' -o -name '*fetch*' \) ! -name '*.test.*' ! -name '*.spec.*' ! -path '*/node_modules/*' 2>/dev/null | head -10

echo ""
echo "=== STYLING ==="
cnt=$(find "$ROOT/src" \( -name '*.module.css' -o -name '*.module.scss' -o -name '*.styled.*' \) 2>/dev/null | wc -l | tr -d ' ')
[ "$cnt" -gt 0 ] && echo "Scoped style files: $cnt"
{ grep -rlE 'tailwind|@tailwind|@apply' "$ROOT" --include='*.css' 2>/dev/null | head -3 && echo "(uses Tailwind)"; } || true

echo ""
echo "=== TEST FILES ==="
find "$ROOT" \( -name '*.test.*' -o -name '*.spec.*' \) ! -path '*/node_modules/*' 2>/dev/null | wc -l | xargs echo "Total test files:"

echo ""
echo "=== TEMPLATE FILES (download samples, export, email previews) ==="
# Downloadable sample/template files (xlsx, csv, docx that users can download)
find "$ROOT/public" "$ROOT/static" "$ROOT/assets" "$ROOT/src/assets" \
  \( -name '*.xlsx' -o -name '*.xls' -o -name '*.xlsm' \
     -o -name '*.docx' -o -name '*.csv' -o -name '*.ods' \) 2>/dev/null | head -20
# Client-side file-generation libraries in package.json
if [ -f "$ROOT/package.json" ]; then
  grep -Eo '"(xlsx|exceljs|jspdf|pdf-lib|pdfmake|docxtemplater|jszip|file-saver|papaparse|html2canvas|html2pdf)[^"]*"' "$ROOT/package.json" 2>/dev/null | head -10
fi
# Template/export related source files
find "$ROOT/src" \( -name '*export*' -o -name '*download*' -o -name '*template*' -o -name '*report*' \) \
  ! -name '*.test.*' ! -name '*.spec.*' ! -path '*/node_modules/*' 2>/dev/null | head -15

echo ""
echo "=== ENTRY POINTS ==="
for f in src/main.tsx src/main.ts src/main.jsx src/main.js src/index.tsx src/index.ts \
  src/App.tsx src/App.vue src/app/layout.tsx src/app/page.tsx pages/_app.tsx; do
  [ -f "$ROOT/$f" ] && echo "$ROOT/$f"
done
