extends GutTest

const L := CommandBuffer.Direction.LEFT
const R := CommandBuffer.Direction.RIGHT
const U := CommandBuffer.Direction.UP
const D := CommandBuffer.Direction.DOWN

var buffer: CommandBuffer


func before_each() -> void:
	buffer = CommandBuffer.new()


## 0.1초 간격으로 입력을 넣고 마지막 push 결과를 돌려준다.
func _press(directions: Array, start := 0.0, step := 0.1) -> StringName:
	var result: StringName = &""
	for i in directions.size():
		result = buffer.push(directions[i], start + i * step)
	return result


func test_backstep() -> void:
	assert_eq(_press([L, L]), &"backstep")


func test_dash() -> void:
	assert_eq(_press([R, R]), &"dash")


func test_multishot() -> void:
	assert_eq(_press([R, L, R]), &"multishot")


func test_arrow_rain() -> void:
	assert_eq(_press([U, R, D]), &"arrow_rain")


func test_partial_input_does_not_fire() -> void:
	assert_eq(_press([R, L]), &"")
	assert_eq(buffer.get_inputs(), [R, L])


func test_buffer_clears_after_match() -> void:
	_press([R, R])
	assert_eq(buffer.get_inputs(), [])


func test_signal_is_emitted_on_match() -> void:
	watch_signals(buffer)
	_press([U, R, D])
	assert_signal_emitted_with_parameters(buffer, "command_matched", [&"arrow_rain"])


func test_slow_input_resets_buffer() -> void:
	buffer.push(R, 0.0)
	assert_eq(buffer.push(R, 0.5), &"", "0.4초를 넘긴 입력은 이어지지 않는다")
	assert_eq(buffer.get_inputs(), [R])


func test_input_just_within_timeout_continues() -> void:
	buffer.push(L, 0.0)
	assert_eq(buffer.push(L, 0.4), &"backstep")


func test_timeout_is_measured_from_last_input() -> void:
	assert_eq(_press([U, R, D], 0.0, 0.3), &"arrow_rain", "전체 0.6초여도 입력 간격이 0.3초면 인정")


func test_update_clears_stale_partial_input() -> void:
	_press([R, L])
	assert_eq(buffer.update(1.0), &"")
	assert_eq(buffer.get_inputs(), [])


func test_wrong_input_is_dropped_and_rest_is_reused() -> void:
	assert_eq(_press([D, L, L]), &"backstep", "어떤 커맨드도 아닌 ↓는 버리고 ←←로 판정")


func test_multishot_mistake_falls_back_to_backstep() -> void:
	assert_eq(_press([R, L, L]), &"backstep", "→← 다음 ←이면 →를 버리고 ←←로 판정")


func test_overlapping_commands_wait_for_timeout() -> void:
	buffer = CommandBuffer.new({&"short": [R, R], &"long": [R, R, L]})
	assert_eq(_press([R, R]), &"", "더 긴 커맨드가 남아 있으면 바로 발동하지 않는다")
	assert_eq(buffer.update(0.3), &"", "아직 대기 시간 안")
	assert_eq(buffer.update(0.6), &"short", "추가 입력이 없으면 짧은 커맨드로 확정")


func test_overlapping_commands_prefer_longer() -> void:
	buffer = CommandBuffer.new({&"short": [R, R], &"long": [R, R, L]})
	assert_eq(_press([R, R, L]), &"long")
	assert_eq(buffer.update(1.0), &"", "긴 커맨드가 발동하면 짧은 커맨드는 나오지 않는다")


func test_direction_from_event_maps_command_actions() -> void:
	var cases := {
		&"cmd_left": L,
		&"cmd_right": R,
		&"cmd_up": U,
		&"cmd_down": D,
	}
	for action in cases:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = true
		assert_eq(CommandBuffer.direction_from_event(event), cases[action], String(action))


func test_direction_from_event_ignores_release_and_other_actions() -> void:
	var released := InputEventAction.new()
	released.action = &"cmd_left"
	released.pressed = false
	assert_eq(CommandBuffer.direction_from_event(released), -1)

	var other := InputEventAction.new()
	other.action = &"move_left"
	other.pressed = true
	assert_eq(CommandBuffer.direction_from_event(other), -1)


func test_command_input_node_turns_actions_into_commands() -> void:
	var node: CommandInput = add_child_autofree(CommandInput.new())
	watch_signals(node)
	for action in [&"cmd_up", &"cmd_right", &"cmd_down"]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = true
		node._unhandled_input(event)
	assert_signal_emitted_with_parameters(node, "command_matched", [&"arrow_rain"])
