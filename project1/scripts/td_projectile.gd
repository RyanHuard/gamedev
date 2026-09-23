extends Node2D

const URCHIN_BASE_SPLASH_RADIUS := 80.0
const URCHIN_LEVEL_SPLASH_BONUS := 10.0
const URCHIN_WIDE_BLAST_BONUS := 25.0

var projectile_type := "shell"
var target: Node2D
var game: Node2D
var damage := 0.0
var tower_level := 1
var upgrade_a := 0
var upgrade_b := 0
var move_speed := 420.0
var lifetime := 3.0

func setup(type: String, new_target: Node2D, game_node: Node2D, power: float, level: int, new_upgrade_a := 0, new_upgrade_b := 0) -> void:
	projectile_type = type
	target = new_target
	game = game_node
	damage = power
	tower_level = level
	upgrade_a = new_upgrade_a
	upgrade_b = new_upgrade_b
	move_speed = 280.0 if type == "seaweed" else (235.0 if type == "urchin" else 420.0)
	z_index = 6
	queue_redraw()

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0 or not is_instance_valid(target) or target.dead:
		queue_free()
		return
	var destination := target.global_position
	var distance := global_position.distance_to(destination)
	var travel := move_speed * delta
	if distance <= travel + 7.0:
		impact()
		return
	var direction := global_position.direction_to(destination)
	global_position += direction * travel
	rotation = direction.angle()

func impact() -> void:
	if not is_instance_valid(target) or target.dead:
		queue_free()
		return
	if projectile_type == "seaweed":
		if is_instance_valid(game): game.projectile_impact_sound("seaweed")
		var slow_strength := maxf(0.28, 0.58 - upgrade_a * 0.11)
		var slow_duration := 1.75 + upgrade_a * 0.65 + (tower_level - 1) * 0.15
		target.take_damage(damage, slow_strength, slow_duration, "seaweed")
		if upgrade_b > 0 and is_instance_valid(game):
			var spread_radius := 38.0 + upgrade_b * 17.0
			for enemy in game.get_enemies_near(target.position, spread_radius):
				if enemy != target:
					enemy.take_damage(damage * 0.6, minf(0.78, slow_strength + 0.12), slow_duration * 0.75, "seaweed")
	elif projectile_type == "urchin" and is_instance_valid(game):
		var splash_radius := URCHIN_BASE_SPLASH_RADIUS + (tower_level - 1) * URCHIN_LEVEL_SPLASH_BONUS + upgrade_a * URCHIN_WIDE_BLAST_BONUS
		game.spawn_impact_effect("urchin", target.global_position, splash_radius)
		for enemy in game.get_enemies_near(target.position, splash_radius):
			enemy.take_damage(damage, 1.0, 0.0, "urchin")
	else:
		target.take_damage(damage, 1.0, 0.0, "shell")
	queue_free()

func _draw() -> void:
	match projectile_type:
		"seaweed":
			# A twisting seaweed seed with a short trailing leaf.
			draw_rect(Rect2(-7, -2, 5, 4), Color("#17382d"))
			draw_rect(Rect2(-4, -4, 6, 8), Color("#26734d"))
			draw_rect(Rect2(-1, -3, 5, 6), Color("#72d66b"))
		"urchin":
			# A compact spiked orb from the urchin cannon.
			draw_rect(Rect2(-7, -2, 14, 4), Color("#30213e"))
			draw_rect(Rect2(-2, -7, 4, 14), Color("#30213e"))
			draw_rect(Rect2(-5, -5, 10, 10), Color("#6f3f96"))
			draw_rect(Rect2(-2, -2, 4, 4), Color("#c58bed"))
		_:
			# A bright pearl with a readable dark outline and water trail.
			draw_rect(Rect2(-9, -2, 4, 4), Color("#8ad9e8"))
			draw_rect(Rect2(-5, -4, 8, 8), Color("#293842"))
			draw_rect(Rect2(-3, -3, 6, 6), Color("#f8f1d5"))
			draw_rect(Rect2(-2, -2, 2, 2), Color.WHITE)
