# 개발 워크플로우

기능마다 **브랜치를 나눠 구현하고, 테스트를 통과한 뒤 `main`에 병합**합니다.

## 원칙

- `main`은 항상 **실행 가능하고 테스트가 통과하는 상태**를 유지합니다.
- `main`에 직접 커밋하지 않습니다. 모든 변경은 PR로 병합합니다.
- 브랜치 하나에는 작업 하나만 담습니다. 크면 나눕니다.

## 흐름

```
1. 브랜치 생성    main에서 최신 상태로 분기
2. 구현          작은 단위로 자주 커밋
3. 테스트        단위 테스트 작성 + 에디터에서 직접 실행 확인
4. PR 생성       템플릿 작성, CI 통과 확인
5. 리뷰          셀프 리뷰 또는 리뷰어 확인
6. 병합          Squash merge 후 브랜치 삭제
```

### 1. 브랜치 생성

```bash
git switch main
git pull origin main
git switch -c feature/command-input
```

### 2. 구현과 커밋

```bash
git add scripts/input/command_buffer.gd tests/test_command_buffer.gd
git commit -m "feat(input): 커맨드 입력 버퍼 추가"
git push -u origin feature/command-input
```

### 3. 테스트

- 로직(커맨드 판정, 데미지 계산, 재화, 저장)은 **단위 테스트**를 함께 작성합니다.
- 화면·조작이 바뀌는 작업은 에디터에서 실행해 직접 확인하고, PR에 스크린샷이나 GIF를 붙입니다.
- 모바일 입력 관련 작업은 가능하면 실기기나 에뮬레이터에서도 확인합니다.

### 4. PR 생성

- 대상 브랜치: `main`
- 제목: 커밋 메시지 규칙과 같은 형식 (`feat(skill): 멀티샷 구현`)
- 본문: [PR 템플릿](../.github/pull_request_template.md)을 채웁니다.
- 작업 중이면 Draft PR로 열어 둡니다.

### 5~6. 리뷰와 병합

- CI(테스트)가 통과해야 병합합니다.
- 병합 방식은 **Squash merge**를 기본으로 합니다. `main` 히스토리가 PR 단위로 깔끔하게 남습니다.
- 병합 후 작업 브랜치는 삭제합니다.
- `main`이 앞서 나가 충돌이 나면 작업 브랜치에서 `git merge origin/main`(또는 rebase)으로 해결합니다.

## 브랜치 이름 규칙

`<종류>/<짧은-설명>` 형식, 소문자와 하이픈을 씁니다.

| 접두어 | 용도 | 예시 |
| --- | --- | --- |
| `feature/` | 새 기능 | `feature/skill-multishot` |
| `fix/` | 버그 수정 | `fix/dash-wall-clip` |
| `art/` | 도트 그래픽, 애니메이션 | `art/archer-idle` |
| `audio/` | 사운드 | `audio/boss-bgm` |
| `balance/` | 수치 조정 | `balance/boss-hp` |
| `refactor/` | 동작 변경 없는 구조 개선 | `refactor/enemy-state-machine` |
| `docs/` | 문서 | `docs/roadmap` |
| `chore/`, `ci/` | 설정, 빌드, CI | `ci/android-export` |
| `release/` | 출시 준비 | `release/1.0.0` |

## 커밋 메시지 규칙

[Conventional Commits](https://www.conventionalcommits.org/ko/) 형식을 따릅니다.

```
<type>(<scope>): <요약>
```

- type: `feat`, `fix`, `art`, `audio`, `balance`, `refactor`, `test`, `docs`, `chore`, `ci`
- scope 예시: `player`, `enemy`, `boss`, `input`, `skill`, `map`, `ui`, `shop`, `save`

예시: `feat(skill): 화살비 낙하 위치 계산 추가`, `fix(enemy): 후퇴 상태에서 낭떠러지로 떨어지는 문제 수정`

## 에셋 관리

- 이미지·사운드 등 바이너리 파일은 **Git LFS**로 관리합니다(M0에서 설정).
- 원본(`.aseprite`)과 내보낸 파일(`.png`)을 함께 커밋합니다.
- Godot의 `.godot/` 캐시 폴더는 커밋하지 않습니다.

## 버전과 릴리스

- [SemVer](https://semver.org/lang/ko/) 사용: `MAJOR.MINOR.PATCH` (예: `0.1.0` = M1 완료)
- 마일스톤 완료 시 `main`에 태그를 남깁니다: `git tag v0.1.0 && git push origin v0.1.0`

## 저장소 설정 (GitHub)

저장소 관리자가 한 번 설정합니다.

- **Settings > General > Default branch**: `main`
- **Settings > Branches > Branch protection rule** (`main`)
  - Require a pull request before merging
  - Require status checks to pass (M0에서 CI 추가 후)
- **Settings > General > Pull Requests**: Allow squash merging, Automatically delete head branches
