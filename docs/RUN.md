# 실행 가이드

게임을 실행해 보는 방법을 상황별로 정리했습니다. 개발 도구 설치와 프로젝트 설정 값은 [SETUP.md](SETUP.md)를 참고하세요.

| 하고 싶은 것 | 방법 |
| --- | --- |
| 설치 없이 바로 해 보기 | [1. 빌드 받아서 실행](#1-빌드-받아서-실행) |
| 코드를 고치며 실행 | [2. 에디터에서 실행](#2-에디터에서-실행) |
| 조작법 확인 | [3. 조작법](#3-조작법) |
| 테스트 돌리기 | [4. 테스트 실행](#4-테스트-실행) |
| 직접 빌드 만들기 | [5. 내보내기(빌드)](#5-내보내기빌드) |

---

## 1. 빌드 받아서 실행

`main`에 PR이 병합될 때마다 GitHub Actions가 빌드를 만듭니다.

1. 저장소의 **Actions** 탭 → 왼쪽에서 **Build** 선택
2. 가장 위의 성공한(✅) 실행 클릭
3. 페이지 아래 **Artifacts**에서 플랫폼에 맞는 파일 다운로드 (GitHub 로그인 필요)

| Artifact | 실행 방법 |
| --- | --- |
| `LeJus-windows-…` | 압축을 풀고 `LeJus.exe` 실행. "Windows의 PC 보호" 창이 뜨면 **추가 정보 → 실행** (서명하지 않은 빌드라서 뜸) |
| `LeJus-linux-…` | 압축을 풀고 `chmod +x LeJus.x86_64 && ./LeJus.x86_64` (압축 과정에서 실행 권한이 빠짐) |
| `LeJus-android-…` | 압축을 풀고 `LeJus.apk`를 기기에 설치. 기기에서 **출처를 알 수 없는 앱 설치**를 허용하거나 `adb install LeJus.apk` |

> Android 빌드는 디버그 서명 빌드입니다. 터치 커맨드 입력은 M6에서 추가되므로, 지금은 화면 확인만 가능합니다.

---

## 2. 에디터에서 실행

### 처음 한 번

1. [Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/) **Standard** 버전을 받습니다 (.NET 버전 아님). 설치 없이 압축만 풀면 됩니다.
2. 저장소를 받습니다. 에셋 때문에 Git LFS가 필요합니다.
   ```bash
   git lfs install
   git clone https://github.com/akqjq1000/LeJus-Game.git
   ```
3. Godot 실행 → 프로젝트 매니저에서 **Import** → `LeJus-Game/project.godot` 선택 → **Import & Edit**
4. 처음 열 때 에셋 임포트가 진행됩니다. 하단 진행 표시가 끝날 때까지 기다립니다.

### 실행

| 단축키 | 동작 |
| --- | --- |
| `F5` | 메인 씬(`scenes/main.tscn`) 실행 |
| `F6` | 지금 열어 둔 씬만 실행 (예: 몬스터 씬 단독 확인) |
| `F8` | 실행 중인 게임 종료 |

창 크기는 1280×720으로 열리고, 화면은 640×360 기준 해상도를 정수 배율로 키워서 보여 줍니다. 창 크기를 바꾸면 도트가 깨지지 않는 배율로만 커집니다.

### 명령줄에서 실행

에디터를 열지 않고 게임만 띄울 때:

```bash
cd LeJus-Game
godot --path .        # 게임 실행
godot -e --path .     # 에디터로 열기
```

`godot`은 내려받은 실행 파일 경로입니다. (예: Windows `Godot_v4.7.2-stable_win64.exe`, macOS `/Applications/Godot.app/Contents/MacOS/Godot`)

---

## 3. 조작법

### 지금 메인 씬에서 할 수 있는 것 (M1 진행 중)

현재 메인 씬은 개발 확인용입니다. 궁수와 슬라임이 제자리에서 걷고, 방향키로 커맨드를 입력하면 화면 아래에 발동한 스킬 이름이 표시되고 궁수가 활을 쏘는 동작을 합니다. 실제 전투는 M1 사냥터 프로토타입에서 붙습니다.

### 전투 커맨드 (사냥터 · 보스방)

| 스킬 | PC | 게임패드 | 모바일 (M6 예정) |
| --- | --- | --- | --- |
| 백스탭 | `←` `←` | D-pad ← ← | 화면 왼쪽 터치 × 2 |
| 돌진 | `→` `→` | D-pad → → | 화면 오른쪽 터치 × 2 |
| 멀티샷 | `→` `←` `→` | D-pad → ← → | 오른쪽 · 왼쪽 · 오른쪽 |
| 화살비 | `↑` `→` `↓` | D-pad ↑ → ↓ | 위 · 오른쪽 · 아래 |

입력 판정 규칙

- 키와 키 사이가 **0.4초 이내**여야 이어진 커맨드로 인정됩니다. 전체 입력 시간은 상관없습니다.
- 잘못 누른 키는 앞에서부터 버려집니다. 예: `→ ← ←`는 앞의 `→`를 버리고 **백스탭**으로 판정합니다.
- 이동과 기본 공격은 자동입니다. 전투 중 위치 조정은 백스탭·돌진으로 합니다.

### 광장 이동 (M2 예정)

| 동작 | PC | 게임패드 | 모바일 (M6 예정) |
| --- | --- | --- | --- |
| 이동 | 방향키 또는 `W` `A` `S` `D` | D-pad | 가상 패드 |

---

## 4. 테스트 실행

### 에디터에서

1. 하단 패널에서 **GUT** 탭 선택 (안 보이면 **Project > Project Settings > Plugins**에서 Gut 활성화)
2. **Run All** 클릭
3. 초록색 `All tests passed!`가 나오면 통과

### 명령줄에서 (CI와 같은 방식)

```bash
godot --headless --import                      # 처음 한 번, 또는 에셋을 바꾼 뒤
godot --headless -s addons/gut/gut_cmdln.gd    # tests/ 아래 test_*.gd 전부 실행
```

일부만 실행:

```bash
# 파일 이름에 test_command_buffer가 들어간 스크립트만
godot --headless -s addons/gut/gut_cmdln.gd -gselect=test_command_buffer
# 그 안에서 이름에 dash가 들어간 테스트만
godot --headless -s addons/gut/gut_cmdln.gd -gselect=test_command_buffer -gunit_test_name=dash
```

실패하면 종료 코드가 0이 아니고, 아래쪽 `Run Summary`에 실패한 테스트와 줄 번호가 나옵니다.

---

## 5. 내보내기(빌드)

평소에는 [1번](#1-빌드-받아서-실행)처럼 CI 빌드를 쓰면 됩니다. 직접 만들어야 할 때만 아래를 따릅니다.

1. 에디터에서 **Editor > Manage Export Templates → Download and Install** (처음 한 번, 약 1GB)
2. **Project > Export**에서 프리셋(Windows / Linux / Android) 선택 → **Export Project**

명령줄로:

```bash
mkdir -p build/windows
godot --headless --export-release "Windows"    # → build/windows/LeJus.exe
mkdir -p build/linux
godot --headless --export-release "Linux"      # → build/linux/LeJus.x86_64
```

Android는 JDK 17과 Android SDK를 설치하고 **Editor > Editor Settings > Export > Android**에 두 경로를 지정한 뒤:

```bash
mkdir -p build/android
godot --headless --export-debug "Android"      # → build/android/LeJus.apk
```

`build/` 폴더는 커밋하지 않습니다.

---

## 6. 문제 해결

| 증상 | 해결 |
| --- | --- |
| 스프라이트가 흐릿함 | 프로젝트를 다른 Godot 버전으로 열었는지 확인. **Project Settings > Rendering > Textures > Default Texture Filter**가 `Nearest`인지 확인 |
| 이미지가 깨지거나 임포트 오류 | Git LFS 없이 받은 경우입니다. `git lfs install && git lfs pull` 후 에디터 재시작 |
| 열 때 버전 변환 경고가 뜸 | Godot 4.7.2가 아닙니다. 다른 버전으로 저장하면 `project.godot`이 바뀌므로 4.7.2를 씁니다 |
| GUT 탭이 없음 | **Project Settings > Plugins**에서 Gut 활성화 |
| 키를 눌러도 커맨드가 안 나감 | 게임 창을 클릭해 포커스를 준 뒤 입력. 키 사이 간격이 0.4초를 넘지 않게 |
| 명령줄 테스트에서 클래스를 못 찾음 (`Identifier not declared`) | `godot --headless --import`를 먼저 한 번 실행 |
| 내보내기에서 "export templates not found" | 5번의 템플릿 설치를 먼저 진행. 버전이 4.7.2여야 함 |
