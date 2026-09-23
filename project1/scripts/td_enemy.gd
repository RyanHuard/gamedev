extends Node2D

const PlanktonTexture = preload("res://assets/enemies/plankton.png")
const StingrayTexture = preload("res://assets/enemies/stingray.png")
const SeaSpiderTexture = preload("res://assets/enemies/giant_sea_spider.png")

signal reached_goal(enemy: Node2D, damage: int)
signal defeated(enemy: Node2D, reward: int)

var route := PackedVector2Array()
var route_index := 1
var health := 30.0
var max_health := 30.0
var move_speed := 65.0
var reward := 10
var goal_damage := 1
var kind := "plankton"
var path_progress := 0.0
var total_path_length := 1.0
var slow_factor := 1.0
var slow_time := 0.0
var dead := false
var facing_angle := 0.0
var damage_flash := 0.0
var bonus_flash := 0.0
var resist_flash := 0.0

func setup(new_route: PackedVector2Array, data: Dictionary) -> void:
	route = new_route
	kind = data.kind
	health = data.hp
	max_health = health
	move_speed = data.speed
	reward = data.reward
	goal_damage = 4 if kind == "sea_spider" else (2 if kind == "stingray" else 1)
	total_path_length = 0.0
	for i in range(route.size() - 1):
		total_path_length += route[i].distance_to(route[i + 1])
	position = route[0]
	z_index = 3
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _process(delta: float) -> void:
	if dead: return
	damage_flash = maxf(damage_flash - delta, 0.0)
	bonus_flash = maxf(bonus_flash - delta, 0.0)
	resist_flash = maxf(resist_flash - delta, 0.0)
	if slow_time > 0.0: slow_time -= delta
	else: slow_factor = 1.0
	var remaining := move_speed * slow_factor * delta
	while remaining > 0.0 and route_index < route.size():
		var target := route[route_index]
		var distance := position.distance_to(target)
		if distance > 0.0 and kind != "sea_spider":
			facing_angle = position.direction_to(target).angle()
		if distance <= remaining:
			position = target
			remaining -= distance
			route_index += 1
			path_progress += distance
		else:
			position += position.direction_to(target) * remaining
			path_progress += remaining
			remaining = 0.0
	if route_index >= route.size():
		dead = true
		reached_goal.emit(self, goal_damage)
	queue_redraw()

func take_damage(amount: float, slow := 1.0, duration := 0.0, damage_type := "normal") -> void:
	if dead: return
	var multiplier := 1.0
	var was_wrapped := slow_factor < 1.0
	if was_wrapped and damage_type in ["shell", "urchin"]:
		multiplier *= 1.40
	if kind == "plankton" and damage_type == "urchin":
		multiplier *= 1.35
	elif kind == "stingray":
		if damage_type == "shell": multiplier *= 0.65
		elif damage_type == "urchin": multiplier *= 1.15
	elif kind == "sea_spider" and slow < 1.0:
		# Boss legs tear through vines, reducing both slow strength and duration.
		slow = lerpf(1.0, slow, 0.45)
		duration *= 0.50
	health -= amount * multiplier
	damage_flash = 0.12
	if multiplier > 1.01: bonus_flash = 0.28
	elif multiplier < 0.99: resist_flash = 0.22
	if slow < slow_factor:
		slow_factor = slow
		slow_time = maxf(slow_time, duration)
	if health <= 0.0:
		dead = true
		defeated.emit(self, reward)
		queue_free()
	else: queue_redraw()

func get_progress_ratio() -> float:
	return path_progress / maxf(total_path_length, 1.0)

func _draw() -> void:
	var radius := 18.0
	var sprite_size := 40.0
	var texture := PlanktonTexture
	if kind == "stingray":
		radius = 24.0
		sprite_size = 52.0
		texture = StingrayTexture
	elif kind == "sea_spider":
		radius = 34.0
		sprite_size = 72.0
		texture = SeaSpiderTexture
	var bob := sin(Time.get_ticks_msec() * 0.006 + float(get_instance_id() % 100)) * 1.2
	var sprite_modulate := Color.WHITE
	if bonus_flash > 0.0: sprite_modulate = Color("#fff19a")
	elif resist_flash > 0.0: sprite_modulate = Color("#8fc9ff")
	elif damage_flash > 0.0: sprite_modulate = Color("#ffb1aa")
	draw_set_transform(Vector2(0, bob), facing_angle if kind != "sea_spider" else 0.0, Vector2.ONE)
	draw_texture_rect(texture, Rect2(-sprite_size / 2.0, -sprite_size / 2.0, sprite_size, sprite_size), false, sprite_modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if bonus_flash > 0.0:
		draw_arc(Vector2.ZERO, radius + 8.0, 0.0, TAU, 20, Color("#ffe66d"), 3.0)
	elif resist_flash > 0.0:
		draw_arc(Vector2.ZERO, radius + 6.0, 0.0, TAU, 20, Color("#76b9ef"), 3.0)
	if slow_factor < 1.0:
		# Two swaying seaweed strands visibly bind slowed enemies.
		var sway := sin(Time.get_ticks_msec() * 0.008) * 0.18
		draw_arc(Vector2.ZERO, radius + 4.0, -2.7 + sway, 0.35 + sway, 18, Color("#8be36f"), 4.0)
		draw_arc(Vector2.ZERO, radius + 1.0, 0.45 - sway, 3.45 - sway, 18, Color("#286e48"), 4.0)
		draw_line(Vector2(-radius - 2.0, 6.0), Vector2(radius + 2.0, -6.0), Color("#69c75f"), 3.0)
		draw_rect(Rect2(-radius - 6.0, 1.0, 7.0, 5.0), Color("#9aea76"))
		draw_rect(Rect2(radius - 1.0, -7.0, 7.0, 5.0), Color("#9aea76"))
	draw_rect(Rect2(-radius, -radius - 9, radius * 2.0, 5), Color("#173047"))
	draw_rect(Rect2(-radius, -radius - 9, radius * 2.0 * clampf(health / max_health, 0, 1), 5), Color("#75ed83"))
