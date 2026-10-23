extends GutTest
## 임시 스프라이트가 애니메이션 코드에서 쓰는 이름과 프레임 수를 갖추고 있는지 확인한다.

const EXPECTED := {
	"res://assets/sprites/placeholder/archer_frames.tres": {&"idle": 2, &"walk": 4, &"shoot": 3},
	"res://assets/sprites/placeholder/slime_frames.tres": {&"walk": 4, &"hit": 1, &"die": 4},
}


func test_sprite_frames_have_expected_animations() -> void:
	for path in EXPECTED:
		var frames := load(path) as SpriteFrames
		assert_not_null(frames, path)
		if frames == null:
			continue
		for animation in EXPECTED[path]:
			assert_true(frames.has_animation(animation), "%s: %s 없음" % [path, animation])
			assert_eq(frames.get_frame_count(animation), EXPECTED[path][animation], "%s: %s 프레임 수" % [path, animation])


func test_one_shot_animations_do_not_loop() -> void:
	var archer := load("res://assets/sprites/placeholder/archer_frames.tres") as SpriteFrames
	var slime := load("res://assets/sprites/placeholder/slime_frames.tres") as SpriteFrames
	assert_false(archer.get_animation_loop(&"shoot"))
	assert_false(slime.get_animation_loop(&"die"))


func test_frames_are_16px() -> void:
	var archer := load("res://assets/sprites/placeholder/archer_frames.tres") as SpriteFrames
	assert_eq(archer.get_frame_texture(&"idle", 0).get_size(), Vector2(16, 16))
	var arrow := load("res://assets/sprites/placeholder/arrow.png") as Texture2D
	assert_eq(arrow.get_size(), Vector2(16, 16))


func test_main_scene_reacts_to_command() -> void:
	var main: Node = add_child_autofree(load("res://scenes/main.tscn").instantiate())
	main.get_node("CommandInput").command_matched.emit(&"dash")
	assert_eq(main.get_node("CommandLabel").text, "돌진 →→")
