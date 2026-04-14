#!/usr/bin/env bash
# Usage: bash discover.sh <backend-path>
# Outputs a lean summary of a backend codebase: structure, counts, file locations.
# Designed to be run by Claude to avoid reading hundreds of files individually.

set -euo pipefail
ROOT="${1:-.}"

echo "=== FOLDER STRUCTURE (3 levels) ==="
find "$ROOT" -maxdepth 3 -type d \
  ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/vendor/*' \
  ! -path '*/__pycache__/*' ! -path '*/.venv/*' ! -path '*/dist/*' \
  ! -path '*/build/*' ! -path '*/.next/*' ! -path '*/.cache/*' | sort

echo ""
echo "=== CONFIG FILES ==="
for f in .env.example .env.sample docker-compose.yml docker-compose.yaml Dockerfile \
  Makefile package.json requirements.txt go.mod Cargo.toml Gemfile pom.xml build.gradle \
  tsconfig.json prisma/schema.prisma; do
  [ -f "$ROOT/$f" ] && echo "$ROOT/$f"
done

echo ""
echo "=== ROUTE/CONTROLLER FILES ==="
# Node/Express/Fastify
grep -rlE 'router\.(get|post|put|patch|delete)|app\.(get|post|put|patch|delete)' "$ROOT/src" --include='*.ts' --include='*.js' 2>/dev/null | while read f; do
  count=$(grep -cE 'router\.|app\.(get|post|put|patch|delete)' "$f" 2>/dev/null || echo 0)
  echo "$f ($count routes)"
done
# Python/Django
grep -rl 'path(' "$ROOT" --include='*.py' 2>/dev/null | grep -i url | head -10
# Python/FastAPI
grep -rl '@app\.\|@router\.' "$ROOT" --include='*.py' 2>/dev/null | while read f; do
  count=$(grep -c '@app\.\|@router\.' "$f" 2>/dev/null || echo 0)
  echo "$f ($count endpoints)"
done
# Go
grep -rl 'HandleFunc\|Handle(' "$ROOT" --include='*.go' 2>/dev/null | head -10
# Laravel
[ -d "$ROOT/routes" ] && ls "$ROOT/routes/"*.php 2>/dev/null
# Rails
[ -f "$ROOT/config/routes.rb" ] && echo "$ROOT/config/routes.rb"

echo ""
echo "=== MODEL/SCHEMA FILES ==="
grep -rl 'class.*Model\|class.*Schema\|@Entity\|@Table\|model ' "$ROOT" \
  --include='*.ts' --include='*.js' --include='*.py' --include='*.go' --include='*.rb' --include='*.java' 2>/dev/null | while read f; do
  lines=$(wc -l < "$f" | tr -d ' ')
  echo "$f ($lines lines)"
done
# Prisma
[ -f "$ROOT/prisma/schema.prisma" ] && echo "Prisma models: $(grep -c '^model ' "$ROOT/prisma/schema.prisma" 2>/dev/null || echo 0)"

echo ""
echo "=== MIGRATION COUNT ==="
find "$ROOT" \( -path '*/migrations/*' -o -path '*/migrate/*' \) -type f ! -name '__init__.py' ! -path '*__pycache__*' 2>/dev/null | wc -l | xargs echo "Total migration files:"

echo ""
echo "=== MIDDLEWARE/AUTH FILES ==="
{ find "$ROOT/src" "$ROOT/app" "$ROOT/lib" \( -name '*middleware*' -o -name '*guard*' -o -name '*auth*' -o -name '*policy*' \) 2>/dev/null || true; } | head -15

echo ""
echo "=== BACKGROUND JOBS/WORKERS ==="
{ find "$ROOT/src" "$ROOT/app" "$ROOT/lib" \( -name '*job*' -o -name '*worker*' -o -name '*queue*' -o -name '*cron*' -o -name '*scheduler*' \) 2>/dev/null || true; } | head -10

echo ""
echo "=== TEST FILES ==="
find "$ROOT" \( -name '*.test.*' -o -name '*.spec.*' -o -name 'test_*' \) ! -path '*/node_modules/*' 2>/dev/null | wc -l | xargs echo "Total test files:"

echo ""
echo "=== SERVICE/BUSINESS LOGIC FILES ==="
{ find "$ROOT/src" "$ROOT/app" "$ROOT/lib" \( -name '*service*' -o -name '*usecase*' -o -name '*use-case*' -o -name '*interactor*' \) 2>/dev/null || true; } | head -15

echo ""
echo "=== TEMPLATE FILES (export/report/email) ==="
# Binary/office templates
find "$ROOT" \( -name '*.xlsx' -o -name '*.xls' -o -name '*.xlsm' \
  -o -name '*.docx' -o -name '*.doc' -o -name '*.odt' \
  -o -name '*.pptx' -o -name '*.ods' \) \
  ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | head -20
# HTML/text email templates
find "$ROOT" -type d \( -name 'templates' -o -name 'email-templates' -o -name 'emails' -o -name 'views' -o -name 'mails' \) \
  ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | head -10
# PDF/report templates (jinja2, handlebars, ejs, blade, twig, mjml)
find "$ROOT" \( -name '*.j2' -o -name '*.jinja' -o -name '*.jinja2' \
  -o -name '*.hbs' -o -name '*.handlebars' \
  -o -name '*.ejs' -o -name '*.blade.php' \
  -o -name '*.twig' -o -name '*.mjml' \) \
  ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null | head -20
# Template-generating libraries in package.json / requirements.txt
if [ -f "$ROOT/package.json" ]; then
  grep -Eo '"(exceljs|xlsx|pdfkit|pdf-lib|puppeteer|playwright|handlebars|ejs|mjml|nodemailer|jspdf|docxtemplater|officegen|jszip)[^"]*"' "$ROOT/package.json" 2>/dev/null | head -10
fi
if [ -f "$ROOT/requirements.txt" ]; then
  grep -iE '^(openpyxl|xlsxwriter|xlrd|reportlab|weasyprint|jinja2|fpdf|python-docx|pdfplumber|xlwt)' "$ROOT/requirements.txt" 2>/dev/null | head -10
fi

echo ""
echo "=== ENTRY POINTS ==="
for f in src/main.ts src/app.ts src/index.ts src/server.ts main.go cmd/main.go \
  manage.py app.py main.py src/main.rs app/Http/Kernel.php config/application.rb; do
  [ -f "$ROOT/$f" ] && echo "$ROOT/$f"
done
