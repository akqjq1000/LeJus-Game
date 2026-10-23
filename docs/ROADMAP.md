# 개발 로드맵

각 마일스톤은 여러 작업 브랜치로 나눠 진행하고, 모든 항목이 `main`에 병합되고 **완료 기준**을 만족하면 끝난 것으로 봅니다.
작업 방식은 [WORKFLOW.md](WORKFLOW.md)를 따릅니다.

| 단계 | 이름 | 핵심 결과물 |
| --- | --- | --- |
| [M0](#m0-프로젝트-셋업) | 프로젝트 셋업 | 빈 Godot 프로젝트가 CI에서 테스트·빌드됨 |
| [M1](#m1-전투-프로토타입) | 전투 프로토타입 | 사냥터 1개에서 궁수가 싸우는 플레이 가능한 빌드 |
| [M2](#m2-맵과-전환) | 맵과 전환 | 광장 ↔ 사냥터 ↔ 보스방 이동 |
| [M3](#m3-보스-전투) | 보스 전투 | 패턴을 가진 보스 1종 |
| [M4](#m4-성장-시스템) | 성장 시스템 | 재화 획득·소비, 스킬 강화, 상점, 저장 |
| [M5](#m5-스탯) | 스탯 | 체력·공격력·치명 확률이 전투에 반영 |
| [M6](#m6-플랫폼-대응) | 플랫폼 대응 | 모바일에서 완전히 플레이 가능 |
| [M7](#m7-출시-준비) | 출시 준비 | 스토어 제출용 빌드 |

---

## M0. 프로젝트 셋업

| 작업 | 브랜치 예시 |
| --- | --- |
| Godot 4 프로젝트 생성, 폴더 구조([README](../README.md#권장-프로젝트-구조)) 적용 | `chore/godot-project` |
| 도트 설정: 기준 해상도 640×360, Nearest 필터, 정수 배율, 픽셀 스냅 | `chore/pixel-settings` |
| `.gitignore`(`.godot/`, `*.import` 캐시 등), `.gitattributes` + Git LFS | `chore/git-lfs` |
| 테스트 프레임워크(GUT 또는 gdUnit4) 설치, 샘플 테스트 1개 | `chore/test-setup` |
| GitHub Actions: PR마다 테스트 실행, `main` 병합 시 PC·Android 빌드 | `ci/github-actions` |
| 입력 액션 정의(`cmd_left/right/up/down`, `move_*`) | `chore/input-map` |

**완료 기준**: PR을 열면 CI에서 테스트가 자동으로 돌고, `main` 병합 시 빌드 산출물이 나온다.

---

## M1. 전투 프로토타입

| 작업 | 브랜치 예시 |
| --- | --- |
| 궁수 자동 이동(진행 방향 전진, 적 사거리 진입 시 정지) | `feature/player-auto-move` |
| 궁수 자동 기본 공격(사거리 내 가장 가까운 적 조준, 화살 투사체) | `feature/player-auto-attack` |
| 일반 몬스터 자유 이동 AI(배회 · 접근 · 후퇴 상태 머신) | `feature/enemy-ai` |
| 피격·사망 처리, 몬스터 스폰 | `feature/combat-core` |
| 커맨드 입력 버퍼 + 판정기 | `feature/command-input` |
| 스킬: 백스탭(←←), 돌진(→→) | `feature/skill-dash` |
| 스킬: 멀티샷(→←→) | `feature/skill-multishot` |
| 스킬: 화살비(↑→↓) | `feature/skill-arrow-rain` |
| 임시 도트 스프라이트(궁수, 몬스터 1종, 화살) | `art/placeholder-sprites` |

**완료 기준**: 사냥터 1개에서 몬스터가 계속 등장하고, 키보드로 스킬 4종을 모두 쓸 수 있다. 커맨드 판정·데미지 계산은 단위 테스트가 있다.

---

## M2. 맵과 전환

| 작업 | 브랜치 예시 |
| --- | --- |
| 타일셋과 광장 맵, 광장 자유 이동(방향키) | `feature/plaza` |
| 사냥터 맵(타일), 구간 진행 | `feature/hunting-ground` |
| 보스방 맵 | `feature/boss-room-map` |
| 씬 전환(포털/메뉴), 전환 연출 | `feature/scene-transition` |

**완료 기준**: 광장에서 사냥터로 들어가 싸우고, 다시 광장으로 돌아올 수 있다.

---

## M3. 보스 전투

| 작업 | 브랜치 예시 |
| --- | --- |
| 보스 1종: 공격 패턴 2~3개, 페이즈 전환 | `feature/boss-1` |
| 보스 체력바, 클리어/실패 처리 | `feature/boss-ui` |

**완료 기준**: 보스방에서 보스를 처치하거나 패배하고 광장으로 돌아온다.

---

## M4. 성장 시스템

| 작업 | 브랜치 예시 |
| --- | --- |
| 재화: 골드·경험치 획득, 다이아 확률 획득(드롭 테이블) | `feature/currency` |
| 스킬 획득·강화(경험치 사용) | `feature/skill-upgrade` |
| 장비·아이템 데이터, 상점(골드 / 다이아), 강화(골드) | `feature/shop` |
| 로컬 저장/불러오기(`user://`) | `feature/save-load` |
| HUD(재화, 스킬 쿨다운) | `feature/hud` |

**완료 기준**: 사냥으로 모은 재화로 스킬과 장비를 강화하고, 게임을 껐다 켜도 유지된다.

---

## M5. 스탯

| 작업 | 브랜치 예시 |
| --- | --- |
| 스탯 시스템(체력, 공격력, 치명 확률)과 장비 연동 | `feature/stats` |
| 데미지 공식에 스탯 반영, 치명타 연출 | `feature/crit` |

**완료 기준**: 장비·강화에 따라 스탯이 바뀌고 전투 결과에 반영된다. 데미지 공식은 단위 테스트가 있다.

---

## M6. 플랫폼 대응

| 작업 | 브랜치 예시 |
| --- | --- |
| 모바일 커맨드 입력: 화면 상·하·좌·우 터치 영역 | `feature/touch-command` |
| 광장 가상 패드 | `feature/virtual-pad` |
| 해상도·화면비 대응, 노치/안전 영역 | `feature/screen-adapt` |
| 앱 일시정지/복귀 시 자동 저장 | `feature/mobile-lifecycle` |
| Android·iOS 실기기 테스트 | — |

**완료 기준**: 모바일 실기기에서 처음부터 보스 처치까지 플레이할 수 있다.

---

## M7. 출시 준비

| 작업 | 브랜치 예시 |
| --- | --- |
| 정식 도트 그래픽 교체 | `art/final-sprites` |
| BGM·효과음 | `audio/sfx-bgm` |
| 밸런싱(데이터 파일 조정) | `balance/...` |
| 타이틀, 설정(사운드, 언어) | `feature/title-settings` |
| 스토어 빌드 서명, 아이콘, 스크린샷 | `release/1.0.0` |

**완료 기준**: Steam/itch.io와 Google Play/App Store에 제출할 빌드가 준비된다.
