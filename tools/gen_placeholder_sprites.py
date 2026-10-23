"""M1 임시 도트 스프라이트 생성기.

정식 그래픽(M7)으로 바꾸기 전까지 쓰는 placeholder다. 모양을 바꾸려면 이 파일을 고치고 다시 실행한다.
결과물은 작고 언제든 다시 만들 수 있어 Git LFS 대상에서 뺐다(.gitattributes 참고).

    python3 tools/gen_placeholder_sprites.py

결과물
- assets/sprites/placeholder/{archer,slime,arrow}.png  스프라이트 시트 (16x16 프레임, 애니메이션마다 한 줄)
- assets/sprites/placeholder/{archer,slime}_frames.tres  AnimatedSprite2D용 SpriteFrames
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "sprites" / "placeholder"
FRAME = 16

# PICO-8 팔레트 일부
C = {
    ".": None,
    "k": (0, 0, 0, 255),
    "n": (29, 43, 83, 255),
    "g": (0, 135, 81, 255),
    "G": (0, 228, 54, 255),
    "b": (171, 82, 54, 255),
    "s": (255, 204, 170, 255),
    "w": (255, 241, 232, 255),
    "y": (255, 236, 39, 255),
    "r": (255, 0, 77, 255),
    "l": (194, 195, 199, 255),
}

# 궁수 기본 몸통 (16x16, 오른쪽을 봄). 다리 2줄은 프레임마다 바꾼다.
ARCHER_BODY = [
    "................",
    "................",
    "......ggg.......",
    ".....ggggg......",
    ".....gssk.......",
    ".....gsss.......",
    "......ss........",
    ".....gggg..b....",
    "....ggggg...b...",
    "....s.ggg...b...",
    "......ggg...b...",
    "......nnn..b....",
    "......nnn.......",
    "......n.n.......",
]
ARCHER_LEGS = {
    "stand": ["......n.n.......", ".....kk.kk......"],
    "step_a": [".....n...n......", "....kk...kk....."],
    "step_b": ["......nn........", "......kkk......."],
}

SLIME_SHAPES = {
    "tall": [
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "......GGGG......",
        ".....GGGGGG.....",
        "....GGwGGwGG....",
        "....GGkGGkGG....",
        "...GGGGGGGGGG...",
        "...GGGGGGGGGG...",
        "...gGGGGGGGGg...",
        "....gggggggg....",
        "................",
        "................",
    ],
    "flat": [
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        ".....GGGGGG.....",
        "...GGGwGGwGGG...",
        "..GGGGkGGkGGGG..",
        "..GGGGGGGGGGGG..",
        "..gGGGGGGGGGGg..",
        "...gggggggggg...",
        "................",
        "................",
    ],
}

ARROW = [
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
    ".ww..........l..",
    "wbbbbbbbbbbbbll.",
    ".ww..........l..",
    "................",
    "................",
    "................",
    "................",
    "................",
    "................",
]


def draw(rows, tint=None):
    img = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            color = C[ch]
            if color is None:
                continue
            if tint is not None:
                color = tint(color)
            img.putpixel((x, y), color)
    return img


def archer(legs, bow_pull=0, bob=0):
    rows = ARCHER_BODY + ARCHER_LEGS[legs]
    rows = [list(r) for r in rows]
    if bow_pull:
        # 활시위를 당기면 화살(y)이 보이고 활이 앞으로 나온다.
        for y in range(7, 12):
            rows[y][11:14] = list("...")
        for y, x in ((7, 12), (8, 13), (9, 13), (10, 13), (11, 12)):
            rows[y][x] = "b"
        for x in range(9 - bow_pull, 13):
            rows[9][x] = "y"
    rows = ["".join(r) for r in rows]
    if bob:
        rows = rows[bob:] + ["." * FRAME] * bob
    return draw(rows)


def fade(alpha):
    return lambda c: (c[0], c[1], c[2], int(c[3] * alpha))


def flash(c):
    return (255, 255, 255, c[3])


def squash(rows, keep):
    """아래쪽 keep 줄만 남겨 납작해지는 사망 연출."""
    blank = ["." * FRAME] * (FRAME - keep)
    return blank + rows[FRAME - keep:]


ANIMATIONS = {
    "archer": [
        ("idle", 4.0, True, [archer("stand"), archer("stand", bob=1)]),
        ("walk", 8.0, True, [archer("step_a"), archer("stand"), archer("step_b"), archer("stand")]),
        ("shoot", 10.0, False, [archer("stand", bow_pull=1), archer("stand", bow_pull=3), archer("stand")]),
    ],
    "slime": [
        ("walk", 6.0, True, [draw(SLIME_SHAPES["tall"]), draw(SLIME_SHAPES["flat"])] * 2),
        ("hit", 10.0, False, [draw(SLIME_SHAPES["tall"], flash)]),
        ("die", 8.0, False, [
            draw(SLIME_SHAPES["flat"]),
            draw(squash(SLIME_SHAPES["flat"], 6), fade(0.75)),
            draw(squash(SLIME_SHAPES["flat"], 4), fade(0.5)),
            draw(squash(SLIME_SHAPES["flat"], 3), fade(0.25)),
        ]),
    ],
}


def write_sheet(name, animations):
    columns = max(len(frames) for _, _, _, frames in animations)
    sheet = Image.new("RGBA", (columns * FRAME, len(animations) * FRAME), (0, 0, 0, 0))
    for row, (_, _, _, frames) in enumerate(animations):
        for col, frame in enumerate(frames):
            sheet.paste(frame, (col * FRAME, row * FRAME))
    sheet.save(OUT / f"{name}.png")


def write_sprite_frames(name, animations):
    subs = []
    anims = []
    for row, (anim, speed, loop, frames) in enumerate(animations):
        refs = []
        for col in range(len(frames)):
            sub_id = f"{anim}_{col}"
            subs.append(
                f'[sub_resource type="AtlasTexture" id="{sub_id}"]\n'
                f'atlas = ExtResource("sheet")\n'
                f"region = Rect2({col * FRAME}, {row * FRAME}, {FRAME}, {FRAME})\n"
            )
            refs.append(f'{{\n"duration": 1.0,\n"texture": SubResource("{sub_id}")\n}}')
        anims.append(
            f'{{\n"frames": [{", ".join(refs)}],\n"loop": {"true" if loop else "false"},\n'
            f'"name": &"{anim}",\n"speed": {speed}\n}}'
        )
    text = (
        '[gd_resource type="SpriteFrames" format=3]\n\n'
        f'[ext_resource type="Texture2D" path="res://assets/sprites/placeholder/{name}.png" id="sheet"]\n\n'
        + "\n".join(subs)
        + "\n[resource]\nanimations = ["
        + ", ".join(anims)
        + "]\n"
    )
    (OUT / f"{name}_frames.tres").write_text(text)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, animations in ANIMATIONS.items():
        write_sheet(name, animations)
        write_sprite_frames(name, animations)
    draw(ARROW).save(OUT / "arrow.png")


if __name__ == "__main__":
    main()
