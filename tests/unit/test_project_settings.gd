extends GutTest
## M0 설정이 깨지지 않았는지 확인하는 테스트.
## 도트 렌더링 설정과 입력 액션은 이후 모든 작업의 전제라서 여기서 고정한다.

const COMMAND_ACTIONS := {
	"cmd_left": KEY_LEFT,
	"cmd_right": KEY_RIGHT,
	"cmd_up": KEY_UP,
	"cmd_down": KEY_DOWN,
}

const MOVE_ACTIONS := {
	"move_left": [KEY_LEFT, KEY_A],
	"move_right": [KEY_RIGHT, KEY_D],
	"move_up": [KEY_UP, KEY_W],
	"move_down": [KEY_DOWN, KEY_S],
}


func _physical_keys(action: StringName) -> Array:
	var keys := []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keys.append(event.physical_keycode)
	return keys


func test_base_resolution_is_640x360() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_width"), 640)
	assert_eq(ProjectSettings.get_setting("display/window/size/viewport_height"), 360)


func test_stretch_uses_integer_viewport_scaling() -> void:
	assert_eq(ProjectSettings.get_setting("display/window/stretch/mode"), "viewport")
	assert_eq(ProjectSettings.get_setting("display/window/stretch/scale_mode"), "integer")


func test_pixel_art_rendering() -> void:
	assert_eq(
		ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter"),
		Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST,
		"기본 텍스처 필터는 Nearest여야 도트가 번지지 않는다"
	)
	assert_true(ProjectSettings.get_setting("rendering/2d/snap/snap_2d_transforms_to_pixel"))


func test_command_actions_are_mapped_to_arrow_keys() -> void:
	for action in COMMAND_ACTIONS:
		assert_true(InputMap.has_action(action), "%s 액션이 없음" % action)
		assert_has(_physical_keys(action), COMMAND_ACTIONS[action], "%s 키 매핑" % action)


func test_move_actions_are_mapped_to_arrows_and_wasd() -> void:
	for action in MOVE_ACTIONS:
		assert_true(InputMap.has_action(action), "%s 액션이 없음" % action)
		var keys := _physical_keys(action)
		for expected in MOVE_ACTIONS[action]:
			assert_has(keys, expected, "%s 키 매핑" % action)


func test_main_scene_loads() -> void:
	var path: String = ProjectSettings.get_setting("application/run/main_scene")
	var scene := load(path) as PackedScene
	assert_not_null(scene, "메인 씬을 불러올 수 없음: %s" % path)
	var root: Node = add_child_autofree(scene.instantiate())
	assert_not_null(root)
