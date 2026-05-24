#!/usr/bin/env bash
# 비자명 작업용 3종 산출물 스캐폴딩 — CLAUDE.md §7
# usage: scaffold.sh [target-dir]   (기본: 현재 디렉토리)
set -euo pipefail

DIR="${1:-.}"
mkdir -p "$DIR"
TODAY="$(date '+%Y-%m-%d')"

CHK="$DIR/checklist.md"
CTX="$DIR/context-notes.md"

if [[ -e "$CHK" ]]; then
  echo "⚠️  이미 존재: $CHK (건드리지 않음)"
else
  cat > "$CHK" <<EOF
# Checklist

> 구체 작업을 체크박스로. 진행하며 체크. 상태 추적용 (이유는 context-notes.md).
> 생성: $TODAY

## 작업
- [ ] (작업 1)
- [ ] (작업 2)
- [ ] (작업 3)

## 검증
- [ ] 테스트 통과 (증거 첨부)
- [ ] 빌드 성공
- [ ] 요구사항 체크리스트 대조
EOF
  echo "✅ 생성: $CHK"
fi

if [[ -e "$CTX" ]]; then
  echo "⚠️  이미 존재: $CTX (건드리지 않음)"
else
  cat > "$CTX" <<EOF
# Context Notes

> 작업 중 내린 결정과 그 이유를 계속 append. 다음 세션이 결정을 재유도하지 않도록.
> 생성: $TODAY

## 결정 기록

### $TODAY
- **결정**: (무엇을 정했나)
  - **이유**: (왜 그렇게 정했나 — 대안과 트레이드오프)
EOF
  echo "✅ 생성: $CTX"
fi

echo "─────────────────────────────"
echo "다음: Plan 본문(무엇을·왜)을 대화 또는 $DIR/plan.md 로 남기세요."
