class_name CommandBuffer
extends RefCounted
## 방향 입력을 시간과 함께 모아 커맨드(스킬)를 판정한다.
##
## 입력 장치와 무관한 순수 로직이다. 키보드·터치 입력은 [CommandInput]이
## [enum Direction]으로 바꿔 [method push]에 넘기고, 매 프레임 [method update]를 부른다.
##
## 판정 규칙
## - 직전 입력 후 [member timeout]초가 지나면 버퍼를 비우고 새로 시작한다.
## - 버퍼가 어떤 커맨드와 같고, 더 긴 커맨드의 앞부분이 아니면 즉시 발동한다.
## - 더 긴 커맨드의 앞부분이기도 하면 [member timeout]까지 기다렸다가
##   추가 입력이 없을 때 발동한다(예: [code]→→[/code]와 [code]→→←[/code]가 함께 있을 때).
## - 어떤 커맨드의 앞부분도 아니면 오래된 입력부터 버려 남은 입력으로 다시 맞춰 본다.

signal command_matched(command: StringName)

enum Direction { LEFT, RIGHT, UP, DOWN }

const DEFAULT_TIMEOUT := 0.4

## 기본 커맨드 표. 키는 스킬 ID, 값은 방향 순서.
const DEFAULT_COMMANDS := {
	&"backstep": [Direction.LEFT, Direction.LEFT],
	&"dash": [Direction.RIGHT, Direction.RIGHT],
	&"multishot": [Direction.RIGHT, Direction.LEFT, Direction.RIGHT],
	&"arrow_rain": [Direction.UP, Direction.RIGHT, Direction.DOWN],
}

const ACTION_TO_DIRECTION := {
	&"cmd_left": Direction.LEFT,
	&"cmd_right": Direction.RIGHT,
	&"cmd_up": Direction.UP,
	&"cmd_down": Direction.DOWN,
}

var timeout: float
var _commands: Dictionary
var _inputs: Array[int] = []
var _last_time := -INF
var _pending: StringName = &""


func _init(commands: Dictionary = DEFAULT_COMMANDS, input_timeout: float = DEFAULT_TIMEOUT) -> void:
	_commands = commands
	timeout = input_timeout


## 방향 입력 하나를 넣는다. 즉시 발동한 커맨드가 있으면 그 이름을, 없으면 빈 이름을 돌려준다.
func push(direction: Direction, time: float) -> StringName:
	if time - _last_time > timeout:
		_inputs.clear()
		_pending = &""
	_last_time = time
	_inputs.append(direction)
	_pending = &""

	while not _inputs.is_empty() and not _is_prefix_of_any(_inputs):
		_inputs.remove_at(0)

	var matched := _exact_match(_inputs)
	if matched == &"":
		return &""
	if _is_prefix_of_longer(_inputs):
		_pending = matched
		return &""
	return _fire(matched)


## 시간을 진행시킨다. 대기 중이던 커맨드가 시간 초과로 확정되면 그 이름을 돌려준다.
func update(time: float) -> StringName:
	if _inputs.is_empty() or time - _last_time <= timeout:
		return &""
	var matched := _pending
	clear()
	if matched == &"":
		return &""
	command_matched.emit(matched)
	return matched


func clear() -> void:
	_inputs.clear()
	_pending = &""


func get_inputs() -> Array[int]:
	return _inputs.duplicate()


## 입력 이벤트를 방향으로 바꾼다. 커맨드 방향키가 눌린 이벤트가 아니면 -1.
static func direction_from_event(event: InputEvent) -> int:
	if event.is_echo():
		return -1
	for action in ACTION_TO_DIRECTION:
		if event.is_action_pressed(action):
			return ACTION_TO_DIRECTION[action]
	return -1


func _fire(command: StringName) -> StringName:
	clear()
	command_matched.emit(command)
	return command


func _exact_match(inputs: Array[int]) -> StringName:
	for command in _commands:
		if _commands[command] == inputs:
			return command
	return &""


func _is_prefix_of_any(inputs: Array[int]) -> bool:
	for command in _commands:
		if _starts_with(_commands[command], inputs):
			return true
	return false


func _is_prefix_of_longer(inputs: Array[int]) -> bool:
	for command in _commands:
		var sequence: Array = _commands[command]
		if sequence.size() > inputs.size() and _starts_with(sequence, inputs):
			return true
	return false


static func _starts_with(sequence: Array, prefix: Array) -> bool:
	if prefix.size() > sequence.size():
		return false
	for i in prefix.size():
		if sequence[i] != prefix[i]:
			return false
	return true
