---
name: plan-scaffold
version: 1.0.0
description: |
  비자명한 작업 시작 전 3종 산출물(Plan + checklist.md + context-notes.md)을 스캐폴딩.
  CLAUDE.md §7을 실행 가능한 스킬로 구현. 다음 세션(사람/에이전트)이 결정을 재유도하지 않고
  이어받을 수 있도록 계획·체크리스트·결정 근거를 파일로 남긴다.

  Triggers: 계획 스캐폴드, plan scaffold, 체크리스트 만들어, checklist 생성,
  context notes, 컨텍스트 노트, 작업 시작 문서, 산출물 3종, plan checklist context.

  NOT FOR: 구현 계획 자체 작성(plan/bkit:pdca plan 사용), 단순 1-2파일 수정(불필요),
  세션 종료 정리(session-wrap), 개발 로그(dev-log).
last_updated: 2026-05-24
triggers:
  - 계획 스캐폴드
  - plan scaffold
  - 체크리스트 만들어
  - checklist 생성
  - context notes
  - 컨텍스트 노트
  - 작업 시작 문서
  - 산출물 3종
---

# Plan Scaffold

> CLAUDE.md §7을 실행 가능하게. 비자명한 작업은 코딩 전 **Plan + checklist.md + context-notes.md** 3종을 먼저 만든다.
> 사용자가 plan만 주고 코딩을 요청하면 멈추고 물어본다: "체크리스트/컨텍스트 노트 먼저 만들까요?"

## 언제 쓰나

- 3개 이상 파일을 건드리는 기능, 아키텍처/스키마 변경, API 변경 등 비자명 작업.
- 여러 세션에 걸칠 작업 (다음 세션이 이어받아야 함).

## 언제 안 쓰나

- 1-2파일 typo/버그 패치 (오버헤드만 됨).
- 이미 plan/checklist가 있는 작업 (업데이트만).

## 실행

```bash
# docs 디렉토리에 checklist.md + context-notes.md 템플릿 생성 (Plan 본문은 대화/별도 파일)
bash ~/.claude/skills/plan-scaffold/scaffold.sh [target-dir]
# 예: bash ~/.claude/skills/plan-scaffold/scaffold.sh docs
```

생성 후:
1. **Plan** — 무엇을 왜 만드는지 한 단락. 대화에 남기거나 `docs/plan.md`로.
2. **checklist.md** — 구체 작업을 체크박스로. 진행하며 체크.
3. **context-notes.md** — 작업 중 내린 결정과 그 이유를 계속 append. 다음 세션이 결정을 재유도하지 않도록.

## 3종 산출물 원칙

| 산출물 | 목적 | 갱신 시점 |
|--------|------|-----------|
| Plan | 무엇을·왜 | 시작 시 1회 (범위 변경 시 갱신) |
| checklist.md | 무엇을 했고 남았나 | 작업 단위마다 체크 |
| context-notes.md | 왜 그렇게 결정했나 | 결정할 때마다 append |

**핵심**: checklist는 "상태", context-notes는 "이유". 둘은 다른 파일. 이유 없는 체크리스트는 다음 세션이 결정을 재발명하게 만든다.
