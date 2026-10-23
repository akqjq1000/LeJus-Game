extends Node2D
## M1 진행 중 임시 메인 씬. 커맨드 입력과 임시 스프라이트를 눈으로 확인하는 용도다.
## 사냥터 프로토타입(feature/hunting-ground-proto)이 생기면 그 씬으로 교체한다.

const COMMAND_NAMES := {
	&"backstep": "백스탭 ←←",
	&"dash": "돌진 →→",
	&"multishot": "멀티샷 →←→",
	&"arrow_rain": "화살비 ↑→↓",
}

@onready var _archer: AnimatedSprite2D = $Archer
@onready var _command_label: Label = $CommandLabel


func _ready() -> void:
	$CommandInput.command_matched.connect(_on_command_matched)


func _on_command_matched(command: StringName) -> void:
	_command_label.text = COMMAND_NAMES.get(command, String(command))
	_archer.play(&"shoot")
	await _archer.animation_finished
	_archer.play(&"walk")
