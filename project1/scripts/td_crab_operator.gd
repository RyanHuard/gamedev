extends Node2D

const CrabTexture = preload("res://assets/player/crab_operator.png")
const CrabWalkATexture = preload("res://assets/player/crab_operator_walk_a.png")
const CrabWalkBTexture = preload("res://assets/player/crab_operator_walk_b.png")
const MOVE_SPEED := 185.0
const OPERATE_RADIUS := 120.0

var game: Node2D
var operated_tower: Node2D
var animation_time := 0.0
var interaction_latched := false
var movement_active := false
var last_move_direction := Vector2.DOWN
var mount_track_position := Vector2.ZERO
var mount_candidate: Node2D

func setup(game_node: Node2D, start_position: Vector2) -> void:
	game = game_node
	process_mode = Node.PROCESS_MODE_PAUSABLE
	position = start_position
	z_index = 14
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _process(delta: float) -> void:
	animation_time += delta
	if not is_instance_valid(game) or game.game_over or game.level_select_menu.visible:
		movement_active = false
		set_mount_candidate(null)
		queue_redraw()
		return
	if is_instance_valid(operated_tower):
		# The crab is physically mounted and cannot walk until the player dismounts.
		movement_active = false
		position = operated_tower.position
		set_mount_candidate(null)
	else:
		var direction := Vector2(
			float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
			float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
		)
		movement_active = direction.length_squared() > 0.0
		if direction.length_squared() > 0.0:
			last_move_direction = direction.normalized()
			var desired_position := position + last_move_direction * MOVE_SPEED * delta
			desired_position.x = clampf(desired_position.x, 24.0, 1256.0)
			desired_position.y = clampf(desired_position.y, 82.0, 696.0)
			position = game.constrain_crab_to_track(desired_position)
		set_mount_candidate(find_mount_candidate())
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
	var nearest: Node2D = find_mount_candidate()
	if not is_instance_valid(nearest):
		var nearby: Node2D = game.get_nearest_tower(position, OPERATE_RADIUS)
		if is_instance_valid(nearby):
			game.show_status("That tower is recharging  •  Mount another tower", 2.2)
		else:
			game.show_status("Move closer to a tower, then press E", 2.0)
		return
	mount_track_position = game.constrain_crab_to_track(position)
	set_mount_candidate(null)
	operated_tower = nearest
	position = operated_tower.position
	operated_tower.set_operated(true)
	game.set_selected_tower(operated_tower)
	var tutorial_handled: bool = game.on_tower_operated(operated_tower)
	if not tutorial_handled:
		game.show_status("Mounted %s  •  Click an enemy to fire" % operated_tower.get_tower_info(operated_tower.tower_type).name, 3.2)
	queue_redraw()

func find_mount_candidate() -> Node2D:
	var nearest: Node2D
	var nearest_distance := OPERATE_RADIUS
	for tower in game.towers:
		if not is_instance_valid(tower) or not tower.can_be_operated():
			continue
		var distance := position.distance_to(tower.position)
		if distance <= nearest_distance:
			nearest = tower
			nearest_distance = distance
	return nearest

func set_mount_candidate(tower: Node2D) -> void:
	if mount_candidate == tower:
		return
	if is_instance_valid(mount_candidate):
		mount_candidate.set_mount_candidate(false)
	mount_candidate = tower
	if is_instance_valid(mount_candidate):
		mount_candidate.set_mount_candidate(true)

func release_tower() -> void:
	var released_tower := operated_tower
	if is_instance_valid(operated_tower):
		operated_tower.set_operated(false)
	operated_tower = null
	position = mount_track_position
	if is_instance_valid(game) and game.selected_tower == released_tower:
		game.set_selected_tower(null)
	queue_redraw()

func exhaust_tower(tower: Node2D) -> void:
	if operated_tower != tower:
		return
	release_tower()
	game.show_status("Operator charge empty  •  Mount another tower while this one recovers", 3.0)

func is_operating() -> bool:
	return is_instance_valid(operated_tower)

func fire_at(screen_position: Vector2) -> bool:
	if not is_instance_valid(operated_tower):
		return false
	return operated_tower.try_manual_fire(screen_position)

func _draw() -> void:
	var scuttle := sin(animation_time * 13.0) * 1.5 if movement_active else 0.0
	if is_instance_valid(operated_tower):
		draw_texture_rect(CrabTexture, Rect2(Vector2(-18, -31), Vector2(36, 36)), false)
	else:
		# A blocky contact shadow and moving sand flecks keep the crab grounded on the seabed.
		draw_rect(Rect2(Vector2(-21, 13), Vector2(42, 7)), Color(0.015, 0.12, 0.18, 0.38))
		draw_rect(Rect2(Vector2(-15, 19), Vector2(30, 3)), Color(0.015, 0.12, 0.18, 0.24))
		if movement_active:
			var behind := -last_move_direction * 22.0
			var sand_alpha: float = 0.28 + abs(sin(animation_time * 13.0)) * 0.20
			draw_rect(Rect2(behind + Vector2(-5, -2), Vector2(4, 3)), Color(0.84, 0.76, 0.52, sand_alpha))
			draw_rect(Rect2(behind + Vector2(5, 3), Vector2(3, 2)), Color(0.84, 0.76, 0.52, sand_alpha * 0.75))
		var walking_texture := CrabTexture
		if movement_active:
			walking_texture = CrabWalkATexture if int(animation_time * 9.0) % 2 == 0 else CrabWalkBTexture
		draw_texture_rect(walking_texture, Rect2(Vector2(-24 + scuttle, -24), Vector2(48, 48)), false)
	var nearest: Node2D
	if is_instance_valid(game) and not is_instance_valid(operated_tower):
		nearest = mount_candidate
	if is_instance_valid(nearest):
		draw_string(ThemeDB.fallback_font, Vector2(-42, -32), "E: OPERATE", HORIZONTAL_ALIGNMENT_CENTER, 84, 12, Color("#fff0a8"))
	elif is_instance_valid(operated_tower):
		draw_string(ThemeDB.fallback_font, Vector2(-44, -48), "E: DISMOUNT", HORIZONTAL_ALIGNMENT_CENTER, 88, 11, Color("#fff0a8"))
