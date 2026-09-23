extends Node2D

const CrabTexture = preload("res://assets/player/crab_operator.png")
const MOVE_SPEED := 255.0
const OPERATE_RADIUS := 76.0

var game: Node2D
var operated_tower: Node2D
var animation_time := 0.0
var interaction_latched := false
var mount_approach_direction := Vector2.DOWN

func setup(game_node: Node2D, start_position: Vector2) -> void:
	game = game_node
	position = start_position
	z_index = 14
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _process(delta: float) -> void:
	animation_time += delta
	if not is_instance_valid(game) or game.game_over or game.level_select_menu.visible:
		queue_redraw()
		return
	if is_instance_valid(operated_tower):
		# The crab is physically mounted and cannot walk until the player dismounts.
		position = operated_tower.position
	else:
		var direction := Vector2(
			float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
			float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
		)
		if direction.length_squared() > 0.0:
			position += direction.normalized() * MOVE_SPEED * delta
			position.x = clampf(position.x, 24.0, 1256.0)
			position.y = clampf(position.y, 82.0, 696.0)
	var pressing_interact := Input.is_key_pressed(KEY_E)
	if pressing_interact and not interaction_latched:
		toggle_operation()
	interaction_latched = pressing_interact
	queue_redraw()

func toggle_operation() -> void:
	if is_instance_valid(operated_tower):
		release_tower()
		game.show_status("Dismounted  •  Move to another tower and press E", 2.2)
		return
	var nearest: Node2D = game.get_nearest_tower(position, OPERATE_RADIUS)
	if not is_instance_valid(nearest):
		game.show_status("Move closer to a tower, then press E", 2.0)
		return
	mount_approach_direction = nearest.position.direction_to(position)
	if mount_approach_direction.length_squared() < 0.01:
		mount_approach_direction = Vector2.DOWN
	operated_tower = nearest
	position = operated_tower.position
	operated_tower.set_operated(true)
	game.set_selected_tower(operated_tower)
	var tutorial_handled: bool = game.on_tower_operated(operated_tower)
	if not tutorial_handled:
		game.show_status("Mounted %s  •  Click an enemy to fire" % operated_tower.get_tower_info(operated_tower.tower_type).name, 3.2)
	queue_redraw()

func release_tower() -> void:
	var dismount_position := position
	if is_instance_valid(operated_tower):
		dismount_position = operated_tower.position + mount_approach_direction * 58.0
		operated_tower.set_operated(false)
	operated_tower = null
	position = Vector2(
		clampf(dismount_position.x, 24.0, 1256.0),
		clampf(dismount_position.y, 82.0, 696.0)
	)
	queue_redraw()

func is_operating() -> bool:
	return is_instance_valid(operated_tower)

func fire_at(screen_position: Vector2) -> bool:
	if not is_instance_valid(operated_tower):
		return false
	return operated_tower.try_manual_fire(screen_position)

func _draw() -> void:
	var bob := sin(animation_time * 8.0) * 2.0
	if is_instance_valid(operated_tower):
		draw_texture_rect(CrabTexture, Rect2(Vector2(-18, -31 + bob), Vector2(36, 36)), false)
	else:
		draw_texture_rect(CrabTexture, Rect2(Vector2(-24, -24 + bob), Vector2(48, 48)), false)
	var nearest: Node2D
	if is_instance_valid(game) and not is_instance_valid(operated_tower):
		nearest = game.get_nearest_tower(position, OPERATE_RADIUS)
	if is_instance_valid(nearest):
		draw_string(ThemeDB.fallback_font, Vector2(-42, -32 + bob), "E: OPERATE", HORIZONTAL_ALIGNMENT_CENTER, 84, 12, Color("#fff0a8"))
	elif is_instance_valid(operated_tower):
		draw_string(ThemeDB.fallback_font, Vector2(-44, -48 + bob), "E: DISMOUNT", HORIZONTAL_ALIGNMENT_CENTER, 88, 11, Color("#fff0a8"))
