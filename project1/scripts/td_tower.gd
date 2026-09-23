extends Node2D

const ShellShooterTexture = preload("res://assets/towers/shell_shooter_v2.png")
const SeaweedSnareTexture = preload("res://assets/towers/seaweed_snare.png")
const UrchinCannonTexture = preload("res://assets/towers/urchin_cannon.png")

var tower_type := "shell"
var game: Node2D
var pad_index := -1
var level := 1
var upgrade_a := 0
var upgrade_b := 0
var cooldown := 0.0
var reload_duration := 0.0
var selected := false
var operated := false
var total_spent := 0
var shot_time := 0.0
var shot_duration := 0.22
var shot_direction := Vector2.RIGHT

static func get_tower_info(type: String) -> Dictionary:
	match type:
		"seaweed": return {"name":"Seaweed Snare", "description":"Wraps and slows enemies. Wrapped targets take bonus damage from Shells and Urchins.", "cost":70, "range":138.0, "damage":3.0, "rate":0.85}
		"urchin": return {"name":"Urchin Cannon", "description":"Splash damage that is strongest against Plankton and seaweed-wrapped enemies.", "cost":90, "range":165.0, "damage":18.0, "rate":1.45}
		_: return {"name":"Shell Shooter", "description":"Fast damage. Pearls hit seaweed-wrapped enemies harder, but Stingrays resist them.", "cost":55, "range":152.0, "damage":9.0, "rate":0.52}

static func get_upgrade_options(type: String) -> Array[Dictionary]:
	match type:
		"seaweed": return [
			{"name":"Deep Roots", "description":"Stronger, longer slowdown."},
			{"name":"Spreading Vines", "description":"Wraps nearby enemies on impact."}
		]
		"urchin": return [
			{"name":"Wide Blast", "description":"Larger splash-damage radius."},
			{"name":"Rapid Spines", "description":"Fires 20% faster per upgrade."}
		]
		_: return [
			{"name":"Rapid Pearls", "description":"Fires 20% faster per upgrade."},
			{"name":"Heavy Pearls", "description":"Deals 35% more damage per upgrade."}
		]

func setup(type: String, game_node: Node2D, new_pad: int) -> void:
	tower_type = type
	game = game_node
	pad_index = new_pad
	total_spent = get_tower_info(type).cost
	z_index = 4
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if operated:
		queue_redraw()
	if shot_time > 0.0:
		shot_time = maxf(shot_time - delta, 0.0)
		queue_redraw()
	if cooldown <= 0.0 and not operated and is_instance_valid(game) and not game.game_over:
		var info := get_tower_info(tower_type)
		var target: Node2D = game.get_target(position, get_effective_range())
		if target: fire(target, info, false)

func fire(target: Node2D, info: Dictionary, operator_boost: bool) -> void:
	var damage: float = info.damage * (1.0 + (level - 1) * 0.20)
	var fire_rate: float = info.rate * pow(0.92, level - 1)
	if tower_type == "shell":
		damage *= 1.0 + upgrade_b * 0.35
		fire_rate *= pow(0.80, upgrade_a)
	elif tower_type == "urchin":
		fire_rate *= pow(0.80, upgrade_b)
	if operator_boost:
		damage *= 1.40
		fire_rate *= 0.55
	else:
		fire_rate *= 1.35
	cooldown = fire_rate
	reload_duration = fire_rate
	shot_direction = position.direction_to(target.position)
	shot_time = shot_duration
	queue_redraw()
	var muzzle_position := global_position + shot_direction * 25.0
	game.spawn_projectile(tower_type, muzzle_position, target, damage, level, upgrade_a, upgrade_b)
	game.tower_fired(tower_type)

func try_manual_fire(screen_position: Vector2) -> bool:
	if not operated or cooldown > 0.0 or not is_instance_valid(game) or game.game_over:
		return false
	var target: Node2D = game.get_target_near_point(screen_position, position, get_effective_range())
	if not is_instance_valid(target):
		return false
	fire(target, get_tower_info(tower_type), true)
	return true

func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()

func set_operated(value: bool) -> void:
	operated = value
	if operated:
		cooldown = minf(cooldown, 0.15)
		reload_duration = maxf(cooldown, 0.15)
	queue_redraw()

func get_reload_progress() -> float:
	if cooldown <= 0.0 or reload_duration <= 0.0:
		return 1.0
	return clampf(1.0 - cooldown / reload_duration, 0.0, 1.0)

func get_upgrade_cost() -> int: return 45 + level * 25

func upgrade(option: int) -> void:
	total_spent += get_upgrade_cost()
	if option == 0: upgrade_a += 1
	else: upgrade_b += 1
	level += 1
	queue_redraw()

func get_refund() -> int: return int(total_spent * 0.7)

func get_summary() -> String:
	var options := get_upgrade_options(tower_type)
	var upgrades: Array[String] = []
	if upgrade_a > 0: upgrades.append("%s x%d" % [options[0].name.to_upper(), upgrade_a])
	if upgrade_b > 0: upgrades.append("%s x%d" % [options[1].name.to_upper(), upgrade_b])
	var suffix := "" if upgrades.is_empty() else " | " + ", ".join(upgrades)
	return "%s LEVEL %d%s" % [get_tower_info(tower_type).name.to_upper(), level, suffix]

func get_effective_range() -> float:
	var result: float = get_tower_info(tower_type).range * (1.0 + (level - 1) * 0.08)
	return result * 1.08 if operated else result

func _draw() -> void:
	if selected or operated:
		var radius: float = get_effective_range()
		var range_color := Color(1.0, 0.78, 0.22, 0.13) if operated else Color(1, 1, 1, 0.08)
		var outline_color := Color("#ffd65a") if operated else Color(1, 1, 1, 0.45)
		draw_circle(Vector2.ZERO, radius, range_color)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 48, outline_color, 2)
	if operated:
		var reload_progress := get_reload_progress()
		var reload_radius := 35.0
		draw_arc(Vector2.ZERO, reload_radius, -PI / 2.0, TAU - PI / 2.0, 24, Color(0.02, 0.12, 0.18, 0.55), 2.5)
		if reload_progress > 0.0:
			var reload_color := Color(0.53, 0.97, 0.87, 0.85) if reload_progress >= 1.0 else Color(1.0, 0.84, 0.35, 0.82)
			draw_arc(Vector2.ZERO, reload_radius, -PI / 2.0, -PI / 2.0 + TAU * reload_progress, 24, reload_color, 2.5)
	var texture := ShellShooterTexture
	if tower_type == "seaweed": texture = SeaweedSnareTexture
	elif tower_type == "urchin": texture = UrchinCannonTexture
	var animation_amount := 0.0
	if shot_time > 0.0:
		animation_amount = sin((1.0 - shot_time / shot_duration) * PI)
	var sprite_offset := Vector2.ZERO
	var sprite_rotation := 0.0
	var sprite_scale := Vector2.ONE
	if tower_type == "shell":
		sprite_offset = -shot_direction * 6.0 * animation_amount
		sprite_scale = Vector2(1.0 + animation_amount * 0.08, 1.0 - animation_amount * 0.10)
	elif tower_type == "seaweed":
		sprite_rotation = shot_direction.x * 0.16 * animation_amount
		sprite_scale = Vector2(1.0 - animation_amount * 0.06, 1.0 + animation_amount * 0.14)
	else:
		sprite_offset = -shot_direction * 8.0 * animation_amount
		sprite_rotation = sin(animation_amount * TAU * 2.0) * 0.05
	draw_set_transform(sprite_offset, sprite_rotation, sprite_scale)
	draw_texture_rect(texture, Rect2(-32, -32, 64, 64), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for i in range(level): draw_rect(Rect2(-12 + i * 10, 29, 6, 6), Color.WHITE)
