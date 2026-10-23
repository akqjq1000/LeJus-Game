# 작업 계획

[ROADMAP.md](ROADMAP.md)의 마일스톤을 실제로 진행할 **작업 단위와 순서**로 풀어 쓴 문서입니다.
진행하면서 상태(✅ 완료 · 🔄 진행 중 · ⬜ 대기)를 갱신합니다.

---

## 지금 할 일 (저장소 관리자)

| # | 할 일 | 위치 |
| --- | --- | --- |
| 1 | 문서 PR(#1) 병합 → 이어서 M0 셋업 PR 병합 | GitHub PR |
| 2 | 기본 브랜치를 `main`으로 지정 | Settings > General > Default branch |
| 3 | `main` 브랜치 보호: PR 필수, 상태 검사 **`GUT unit tests`** 통과 필수 | Settings > Branches |
| 4 | Squash merge 허용, 병합 후 브랜치 자동 삭제 | Settings > General > Pull Requests |
| 5 | 로컬 환경 준비: Godot 4.7.2, Git LFS ([SETUP.md](SETUP.md)) | 개발 PC |

---

## M0. 프로젝트 셋업 ✅

> 저장소 작업 브랜치 제약 때문에 M0의 6개 작업을 PR 하나에 커밋별로 나눠 담았습니다. M1부터는 [WORKFLOW.md](WORKFLOW.md)대로 작업마다 브랜치·PR을 나눕니다.

| 작업 | 결과물 | 상태 |
| --- | --- | --- |
| Godot 4.7.2 프로젝트, 폴더 구조 | `project.godot`, `scenes/main.tscn`, `assets/ scenes/ scripts/ data/ tests/` | ✅ |
| 도트 설정 | 640×360, Nearest, integer 배율, 픽셀 스냅, Compatibility 렌더러 | ✅ |
| `.gitignore`, `.gitattributes` + Git LFS | png·aseprite·wav·ogg·ttf 등 LFS 추적 | ✅ |
| 테스트 프레임워크 | GUT 9.7.1(`addons/gut`), 설정 검증 테스트 6개 | ✅ |
| GitHub Actions | `test.yml`(PR마다 테스트), `build.yml`(`main` 병합 시 Windows·Linux·Android 빌드) | ✅ |
| 입력 액션 | `cmd_*`(방향키·D-pad), `move_*`(방향키·WASD·D-pad) | ✅ |

**완료 기준 확인**: PR에서 `Test` 워크플로가 돌고, `main` 병합 시 `Build` 워크플로가 빌드 아티팩트를 올린다. → 병합 후 `v0.0.1` 태그.

---

## M1. 전투 프로토타입 (목표 `v0.1.0`)

의존 관계 순서대로 진행합니다. 같은 단계 안의 작업은 병렬로 해도 됩니다.

```
1단계  art/placeholder-sprites ─┐
       feature/command-input ───┼─────────────┐
2단계  feature/player-auto-move ┤             │
       feature/enemy-ai ────────┤             │
3단계  feature/combat-core ─────┤ (피격·사망·스폰)
       feature/player-auto-attack             │
4단계  feature/skill-dash ◄───────────────────┤
       feature/skill-multishot ◄──────────────┤
       feature/skill-arrow-rain ◄─────────────┘
```

| 단계 | 브랜치 | 세부 작업 | 테스트 | 상태 |
| --- | --- | --- | --- | --- |
| 1 | `art/placeholder-sprites` | 궁수(idle·walk·shoot), 몬스터 1종(walk·hit·die), 화살 16×16 스프라이트. `tools/gen_placeholder_sprites.py`로 생성해 `assets/sprites/placeholder/`에 둠(LFS 제외) | 애니메이션 이름·프레임 수 테스트 | ✅ |
| 1 | `feature/command-input` | `scripts/input/command_buffer.gd`: 입력+시각 기록, 0.4초 타임아웃, 긴 커맨드 우선 매칭(`→←→` vs `→→`), 매칭 시그널. 씬에서는 `CommandInput` 노드로 사용 | **단위 테스트 필수**: 각 커맨드 인식, 타임아웃 초기화, 겹치는 커맨드 구분 | ✅ |
| 2 | `feature/player-auto-move` | `scenes/player/archer.tscn`(CharacterBody2D), 진행 방향 자동 전진, 사거리 내 적 감지 시 정지 | 정지 조건 단위 테스트 | ⬜ |
| 2 | `feature/enemy-ai` | 상태 머신(배회·접근·후퇴), 데이터(`data/enemies/*.tres`)로 속도·사거리 분리 | 상태 전이 단위 테스트 | ⬜ |
| 3 | `feature/combat-core` | `Hurtbox/Hitbox`, 체력 컴포넌트, 사망 처리, 스포너(간격·최대 수) | 데미지 계산 단위 테스트 | ⬜ |
| 3 | `feature/player-auto-attack` | 가장 가까운 적 조준, 화살 투사체, 공격 간격 | 타깃 선택 단위 테스트 | ⬜ |
| 4 | `feature/skill-dash` | 백스탭(`←←`), 돌진(`→→`): 이동 거리·무적 시간·쿨다운 | 쿨다운 단위 테스트 | ⬜ |
| 4 | `feature/skill-multishot` | 멀티샷(`→←→`): 범위 내 최대 3명, 강한 공격 | 타깃 수 제한 테스트 | ⬜ |
| 4 | `feature/skill-arrow-rain` | 화살비(`↑→↓`): 최대 사정거리 지점에 5발 낙하 | 낙하 위치 계산 테스트 | ⬜ |
| — | `feature/hunting-ground-proto` | 위 요소를 묶은 임시 사냥터 씬을 메인 씬으로 지정 | 실행 확인 | ⬜ |

공통 설계 원칙

- 스킬은 `scripts/skills/skill.gd`(기본 클래스: 커맨드, 쿨다운, 실행) + 스킬별 `Resource` 데이터로 만든다. M4 강화가 데이터만 바꾸면 되도록.
- 수치는 코드에 하드코딩하지 않고 `data/`에 둔다.
- 커맨드 판정은 `Input` 대신 `InputEvent`를 받는 순수 로직으로 만들어 테스트와 M6 터치 입력을 쉽게 한다.

---

## M2 ~ M7 개요

세부 작업은 각 마일스톤을 시작할 때 이 문서에 같은 형식으로 펼칩니다. 작업 목록은 [ROADMAP.md](ROADMAP.md)를 기준으로 합니다.

| 단계 | 버전 | 먼저 정할 것 / 위험 요소 |
| --- | --- | --- |
| M2 맵과 전환 | `v0.2.0` | 타일 크기(16×16 권장), TileMapLayer vs LDtk 결정 |
| M3 보스 전투 | `v0.3.0` | 보스 패턴 기획 2~3개, 페이즈 전환 조건 |
| M4 성장 시스템 | `v0.4.0` | 저장 데이터 버전 관리(필드 추가 시 마이그레이션), 다이아 드롭 확률 |
| M5 스탯 | `v0.5.0` | 데미지 공식 확정 (공격력·치명 배율) |
| M6 플랫폼 대응 | `v0.6.0` | 터치 4분할 영역과 HUD 겹침, 실기기 확보, iOS 빌드용 macOS 환경 |
| M7 출시 준비 | `v1.0.0` | 스토어 개발자 계정, 서명 키(GitHub Secrets), 아트·사운드 외주 여부 |

> iOS 빌드는 macOS + Xcode가 필요해 현재 CI(ubuntu)에는 포함하지 않았습니다. M6에서 macOS 러너 또는 로컬 Mac으로 추가합니다.
