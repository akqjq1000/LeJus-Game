class_name CommandInput
extends Node
## [CommandBuffer]를 씬에 붙이는 노드. cmd_* 입력을 받아 커맨드 발동 시그널을 낸다.
##
## 모바일 터치 영역(M6)도 같은 cmd_* 액션을 발생시키면 이 노드를 그대로 쓴다.

signal command_matched(command: StringName)

@export var timeout := CommandBuffer.DEFAULT_TIMEOUT

var buffer: CommandBuffer


func _ready() -> void:
	buffer = CommandBuffer.new(CommandBuffer.DEFAULT_COMMANDS, timeout)
	buffer.command_matched.connect(command_matched.emit)


func _unhandled_input(event: InputEvent) -> void:
	var direction := CommandBuffer.direction_from_event(event)
	if direction == -1:
		return
	buffer.push(direction, _now())
	get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	buffer.update(_now())


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
