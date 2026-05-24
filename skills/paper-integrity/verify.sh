#!/usr/bin/env bash
# 논문 done 게이트 — CLAUDE.md §11.8 빌드+정합성 검증 자동화
# usage: verify.sh <paper-dir> [main] [abstract-min] [abstract-max] [page-limit]
set -uo pipefail

DIR="${1:?usage: verify.sh <paper-dir> [main] [abs-min] [abs-max] [page-limit]}"
MAIN="${2:-main}"
ABS_MIN="${3:-150}"
ABS_MAX="${4:-250}"
PAGE_LIMIT="${5:-0}"   # 0 = 한도 미지정(경고만)

cd "$DIR" || { echo "❌ dir not found: $DIR" >&2; exit 2; }
[[ -f "$MAIN.tex" ]] || { echo "❌ $MAIN.tex not found in $DIR" >&2; exit 2; }

FAIL=0
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "─── clean build: $DIR/$MAIN.tex ───"
rm -f ./*.aux ./*.bbl ./*.blg ./*.log ./*.out
pdflatex -interaction=nonstopmode "$MAIN.tex" > "$TMP/p1.log" 2>&1
bibtex "$MAIN"                                  > "$TMP/b.log"  2>&1
pdflatex -interaction=nonstopmode "$MAIN.tex" > "$TMP/p2.log" 2>&1
pdflatex -interaction=nonstopmode "$MAIN.tex" > "$TMP/p3.log" 2>&1

if [[ ! -f "$MAIN.pdf" ]]; then
  echo "❌ build produced no PDF — see $TMP/p3.log"; exit 1
fi

# 1) warnings / undefined refs
WARN=$(grep -ci "warning\|undefined" "$MAIN.log" 2>/dev/null || echo 0)
if [[ "$WARN" -eq 0 ]]; then echo "✅ warnings/undefined: 0"
else echo "❌ warnings/undefined: $WARN"; FAIL=1
  grep -i "warning\|undefined" "$MAIN.log" | head -8 | sed 's/^/     /'
fi

# 2) abstract 단어수
WORDS=$(perl -0777 -ne 'if(/\\begin\{abstract\}(.*?)\\end\{abstract\}/s){my $a=$1;$a=~s/\\[a-zA-Z]+\{?[^}]*\}?//g;my @w=split /\s+/,$a;print scalar(grep{/\S/}@w)}' "$MAIN.tex" 2>/dev/null)
WORDS=${WORDS:-0}
if [[ "$WORDS" -ge "$ABS_MIN" && "$WORDS" -le "$ABS_MAX" ]]; then
  echo "✅ abstract: $WORDS words (한도 $ABS_MIN-$ABS_MAX)"
else
  echo "❌ abstract: $WORDS words (한도 $ABS_MIN-$ABS_MAX 벗어남)"; FAIL=1
fi

# 3) 페이지 수
PAGES=$(pdfinfo "$MAIN.pdf" 2>/dev/null | awk '/^Pages/{print $2}')
PAGES=${PAGES:-?}
if [[ "$PAGE_LIMIT" -gt 0 && "$PAGES" != "?" ]]; then
  if [[ "$PAGES" -le "$PAGE_LIMIT" ]]; then echo "✅ pages: $PAGES (한도 $PAGE_LIMIT)"
  else echo "❌ pages: $PAGES (한도 $PAGE_LIMIT 초과)"; FAIL=1; fi
else
  echo "ℹ️  pages: $PAGES (한도 미지정)"
fi

# 4) bib ↔ cite 정합성
BIB=""
for b in refs/references.bib references.bib refs/*.bib ./*.bib; do
  [[ -f "$b" ]] && BIB="$b" && break
done
if [[ -n "$BIB" ]]; then
  DIFF=$(diff \
    <(grep -oE '^@[a-z]+\{[^,]+' "$BIB" | sed 's/^@[a-z]*{//' | sort -u) \
    <(grep -oE '\\cite[a-z]*\{[^}]+\}' "$MAIN.tex" | grep -oE '\{[^}]+\}' | tr ',' '\n' | tr -d '{} ' | sort -u) )
  if [[ -z "$DIFF" ]]; then echo "✅ bib↔cite: 완전 일치 (diff 0줄)"
  else echo "❌ bib↔cite 불일치:"; echo "$DIFF" | sed 's/^/     /'; FAIL=1; fi
else
  echo "⚠️  bib 파일을 못 찾음 — bib↔cite 검증 생략"
fi

echo "─────────────────────────────"
if [[ "$FAIL" -eq 0 ]]; then echo "판정: ✅ PASS"; exit 0
else echo "판정: ❌ FAIL — done 마킹 금지"; exit 1; fi
