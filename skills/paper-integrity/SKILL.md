---
name: paper-integrity
version: 1.0.0
description: |
  논문·기술 보고서 작성 정직성(integrity) 게이트. CLAUDE.md §11을 실행 가능한 스킬로 구현.
  수치 출처 검증, 데이터 출처 구분(시뮬/합성/실측/이론), 미수행 항목 정직 disclosure,
  강한 표현(first/comprehensive 등) 차단, self-plagiarism 회피, BibTeX 1:1 매칭,
  그리고 done 마킹 전 §11.8 빌드+검증 grep 게이트를 verify.sh로 실행.

  Triggers: 논문 검증, 논문 정직성, paper integrity, paper verify, done 게이트, 검증 게이트,
  논문 done 체크, bib 정합성, abstract 단어수, 페이지 한도, integrity check,
  논문 빌드 검증, reject 위험, 과장 표현 점검.

  NOT FOR: 논문 내용/문장 작성 자체(별도), 한국 학회 워크플로우(kr-conference-paper 사용),
  PDF 변환(make-pdf), 단행본 빌드(book-builder), 연구계획서(plan-research).
last_updated: 2026-05-24
triggers:
  - 논문 검증
  - 논문 정직성
  - paper integrity
  - paper verify
  - done 게이트
  - 검증 게이트
  - bib 정합성
  - abstract 단어수
  - integrity check
  - 논문 빌드 검증
  - reject 위험
  - 과장 표현 점검
---

# Paper Integrity Gate

> CLAUDE.md §11(논문 작성 정직성)을 실행 가능한 게이트로 구현. **검증된 것만 쓴다.**
> 추측·시뮬레이션·미수행을 실측처럼 표기하면 retraction 사유다.

## 언제 쓰나

- 논문/기술 보고서 산출물을 `done` 처리하기 직전 (필수).
- 수치·표·abstract·conclusion 정합성이 의심될 때.
- reviewer 1차 인상에서 reject될 표현/과장이 있는지 점검할 때.

## 실행: §11.8 검증 게이트

```bash
# paper-dir = main.tex 가 있는 디렉토리, main = 파일명(확장자 제외)
bash ~/.claude/skills/paper-integrity/verify.sh <paper-dir> [main] [abstract-min] [abstract-max] [page-limit]
# 예: bash ~/.claude/skills/paper-integrity/verify.sh ~/02_RESEARCH/abada-ai/papers/foo main 150 250 8
```

verify.sh 가 수행하는 것:
1. aux/bbl/blg/log/out 제거 후 `pdflatex → bibtex → pdflatex × 2` 클린 빌드.
2. `main.log`의 warning/undefined 카운트 (기대값 0).
3. abstract 단어수 (학회 한도 내 확인).
4. PDF 페이지 수 (한도 내 확인).
5. bib ↔ cite diff (기대 출력 0줄 = 완전 일치).

**게이트 통과 조건**: warnings 0, undefined 0, abstract 한도 내, pages 한도 내, bib↔cite diff 0줄.
하나라도 실패하면 **done 마킹 금지**. 자기 보고로 "정합성 audit 완료" 표기는 verify.sh 출력이 동반되지 않으면 무효.

## 수동 체크리스트 (verify.sh 가 자동화 못 하는 항목)

### 수치 정직성 (§11.1)
- [ ] 본문 모든 수치가 raw data/log/측정 파일에서 소수점 4자리까지 일치.
- [ ] caption + table + abstract + conclusion 같은 수치 4곳 일치 (grep 확인).
- [ ] 출처 명시: 데이터시트 페이지 / cite / 시뮬 시드 / 측정 장비·날짜.
- [ ] 이론 최고치 vs typical vs worst-case vs 측정값 구분.

### 데이터 출처 구분 (§11.2 — 가장 흔한 reject 사유)
- [ ] 시뮬레이션: caption + Limitations 둘 다 "simulation-based" 명시.
- [ ] 합성 데이터: "synthetic" + 생성 방법(분포·시드·파라미터).
- [ ] 실측: 장비명·시리얼·교정일·환경 조건.
- [ ] 이론치: 식 + 식 출처 인용.
- [ ] Calibrated simulation: "estimated from production statistics with framework overhead factors" 한 줄 명시.

### 미수행 disclosure (§11.3)
- [ ] 학습 미완을 "complete"로 표기 금지. "training ongoing" 식으로 명시.
- [ ] 미측정 항목은 "expected"/"estimated"로 명시.
- [ ] L1~L_N 번호로 구체 기술.
- [ ] "future work"로 limitation 가리지 않기.

### 강한 표현 차단 (§11.4)
- [ ] first / comprehensive / unified / state-of-the-art / novel / end-to-end 사용 전 자문.
- [ ] 써야 하면 scoped/negated 형태로 ("to our knowledge, the first reported measurement of X on substrate Y").

### Self-plagiarism (§11.5)
- [ ] 같은 저자 별도 논문은 paraphrase 필수.
- [ ] 같은 데이터 재사용 시 기여(method) 분리 명확.
- [ ] 자기 인용 시 "our prior work [N]" 명시.

### 윤리/IRB/PII (§11.6)
- [ ] 사용자 데이터 IRB 면제/동의 절차 명시.
- [ ] PII hash, k-anonymity (k≥5).
- [ ] Ethics 섹션 존재.

### Reject 확률 점추정 (§11.9)
- [ ] push back 받아도 데이터 없이 톤 조정 금지 (no sycophancy).
- [ ] "이 정도면 통과" 표현 금지.
- [ ] 항목별 구체 수치 + 종합 점추정 + 학회 성격(예: IEEE Access soundness-first) 보정.

### 양국어 산출 (§11.10)
- [ ] ko / en 두 버전 모두 빌드 클린 + 수치 일치 (ko만 검증하고 done 금지).

## 출력 형식

```
📋 Paper Integrity Gate — <paper-dir>
[자동] warnings=0  undefined=0  abstract=NNN words (한도 150-250)  pages=N (한도 8)  bib↔cite diff=0줄
[수동] 미통과 항목: <목록 또는 "없음">
판정: PASS / FAIL — FAIL 시 done 금지
```
