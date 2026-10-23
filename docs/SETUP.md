# 개발 환경 설정

처음 저장소를 받아 실행·테스트하기까지 필요한 준비입니다.

## 1. 필요한 도구

| 도구 | 버전 | 용도 |
| --- | --- | --- |
| [Godot](https://godotengine.org/download) | **4.7.2** (Standard, GDScript) | 에디터, 실행, 내보내기 |
| Git + [Git LFS](https://git-lfs.com/) | 최신 | 소스와 바이너리 에셋 관리 |
| [Aseprite](https://www.aseprite.org/) | 선택 | 도트 그래픽 |
| JDK 17 + Android SDK | 선택 | 로컬에서 Android 빌드할 때만 (CI는 자동) |

> Godot 버전은 CI(`.github/workflows/*.yml`의 `GODOT_VERSION`)와 같게 맞춥니다. 올릴 때는 PR 하나로 CI와 함께 바꿉니다.

## 2. 저장소 받기

```bash
git lfs install            # 컴퓨터에서 한 번만
git clone https://github.com/akqjq1000/LeJus-Game.git
cd LeJus-Game
```

LFS 없이 받았다면 `git lfs pull`로 에셋을 내려받습니다.

## 3. 에디터로 열기

1. Godot 실행 → **Import** → 저장소의 `project.godot` 선택
2. 첫 실행 시 에셋 임포트가 끝날 때까지 기다립니다 (`.godot/` 캐시 생성, 커밋하지 않음)
3. `F5`로 실행하면 640×360 기준 화면에 `LeJus` 글자가 나옵니다

## 4. 테스트 실행

테스트 프레임워크는 [GUT](https://github.com/bitwes/Gut) 9.7.1이며 `addons/gut/`에 포함되어 있습니다.

**에디터에서**: 하단 패널 **GUT** 탭 → **Run All**

**명령줄에서** (CI와 같은 방식):

```bash
godot --headless --import                      # 최초 1회 또는 에셋 변경 후
godot --headless -s addons/gut/gut_cmdln.gd    # tests/ 아래 test_*.gd 전부 실행
```

- 설정은 `.gutconfig.json`에 있습니다.
- 테스트 파일은 `tests/unit/test_<대상>.gd`로 만들고 `extends GutTest`로 시작합니다.

## 5. 프로젝트 설정 요약

M0에서 고정한 값입니다. 바꾸면 `tests/unit/test_project_settings.gd`가 실패하므로, 의도한 변경이면 테스트도 함께 고칩니다.

| 항목 | 값 |
| --- | --- |
| 기준 해상도 | 640×360 (창 기본 1280×720) |
| Stretch | mode `viewport`, aspect `keep_height`, scale `integer` |
| 텍스처 필터 | Nearest |
| 픽셀 스냅 | 2D transform·vertex 스냅 On |
| 렌더러 | Compatibility (PC·모바일 공통, 저사양 대응) |
| 모바일 화면 방향 | 가로(센서) |

### 입력 액션

| 액션 | 키보드 | 게임패드 | 용도 |
| --- | --- | --- | --- |
| `cmd_left` / `cmd_right` / `cmd_up` / `cmd_down` | 방향키 | D-pad | 전투 커맨드 입력 (사냥터·보스방) |
| `move_left` / `move_right` / `move_up` / `move_down` | 방향키, WASD | D-pad | 광장 자유 이동 |

모바일 터치 영역(상·하·좌·우)은 M6에서 같은 `cmd_*` 액션을 발생시키도록 연결합니다.

## 6. 빌드 (내보내기)

`export_presets.cfg`에 프리셋 3개가 있습니다: **Windows**, **Linux**, **Android**.

```bash
mkdir -p build/windows
godot --headless --export-release "Windows"    # build/windows/LeJus.exe
```

- export 템플릿이 필요합니다: 에디터 **Editor > Manage Export Templates > Download and Install**
- `build/`는 커밋하지 않습니다.
- Android는 JDK 17과 Android SDK 경로를 **Editor Settings > Export > Android**에 지정해야 합니다. 서명은 지금은 디버그 키만 쓰고, 스토어용 키는 M7에서 GitHub Secrets로 관리합니다.

## 7. CI (GitHub Actions)

| 워크플로 | 언제 | 하는 일 |
| --- | --- | --- |
| `Test` (`test.yml`) | 모든 PR, `main` 푸시 | GUT 테스트 실행. 실패하면 병합 불가(브랜치 보호 설정 시) |
| `Build` (`build.yml`) | `main` 푸시, 수동 실행, 빌드 설정을 바꾸는 PR | Windows·Linux 릴리스, Android 디버그 APK 빌드 → Actions 아티팩트로 업로드 |

빌드 결과물은 Actions 실행 페이지 하단 **Artifacts**에서 내려받습니다.
