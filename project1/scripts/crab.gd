extends CharacterBody2D

signal hit
signal died
signal jumped

const RUN_SPEED := 250.0
const GRAVITY := 1650.0
const JUMP_SPEED := -700.0
const COYOTE_TIME := 0.11
const JUMP_BUFFER := 0.13

var active := true
var invulnerable := 0.0
var _coyote := 0.0
var _jump_buffer := 0.0
var _anim_time := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = 1
	collision_mask = 2
	var collision := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 22.0
	capsule.height = 44.0
	collision.shape = capsule
	collision.position.y = 2
	add_child(collision)
	queue_redraw()

func _physics_process(delta: float) -> void:
	_anim_time += delta
	invulnerable = maxf(0.0, invulnerable - delta)
	if not active:
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
		move_and_slide()
		queue_redraw()
		return

	velocity.x = RUN_SPEED
	if is_on_floor():
		_coyote = COYOTE_TIME
	else:
		_coyote -= delta
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump"):
		_jump_buffer = JUMP_BUFFER
	else:
		_jump_buffer -= delta

	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_SPEED
		_jump_buffer = 0.0
		_coyote = 0.0
		jumped.emit()

	# Releasing jump early gives the player precise short hops.
	if Input.is_action_just_released("jump") and velocity.y < -210.0:
		velocity.y = -210.0

	move_and_slide()
	queue_redraw()
	if global_position.y > 850:
		died.emit()

func bounce() -> void:
	velocity.y = -850.0
	jumped.emit()

func take_hit() -> void:
	if invulnerable > 0.0 or not active:
		return
	invulnerable = 1.0
	velocity.y = -430.0
	hit.emit()

func _draw() -> void:
	if invulnerable > 0.0 and int(invulnerable * 12.0) % 2 == 0:
		return
	var bob := sin(_anim_time * 14.0) * (2.0 if is_on_floor() else 0.5)
	var claw_wave := sin(_anim_time * 11.0) * 5.0
	# Legs.
	for side in [-1.0, 1.0]:
		for i in range(3):
			var sy: float = side
			var start := Vector2(sy * (15 + i * 3), 12 + bob)
			var finish := Vector2(sy * (27 + i * 7), 22 + abs(i - 1) * 3 + bob)
			draw_line(start, finish, Color("#c84b45"), 6, true)
	# Claws.
	for side in [-1.0, 1.0]:
		var arm_end := Vector2(side * 35, -8 + bob + claw_wave * side)
		draw_line(Vector2(side * 18, -2 + bob), arm_end, Color("#ef6a57"), 8, true)
		draw_circle(arm_end, 11, Color("#f47a60"))
		draw_circle(arm_end + Vector2(side * 6, -6), 7, Color("#ff9a72"))
	# Shell, face, and eyes.
	draw_crab_ellipse(Vector2(0, 4 + bob), Vector2(28, 21), Color("#e6534d"))
	draw_arc(Vector2(0, 4 + bob), 28, 0, TAU, 24, Color("#ff9270"), 3)
	for side in [-1.0, 1.0]:
		draw_line(Vector2(side * 11, -10 + bob), Vector2(side * 13, -22 + bob), Color("#f47a60"), 5, true)
		draw_circle(Vector2(side * 13, -24 + bob), 6, Color.WHITE)
		draw_circle(Vector2(side * 15, -24 + bob), 2.5, Color("#102c3d"))
	draw_arc(Vector2(0, 2 + bob), 9, 0.2, PI - 0.2, 12, Color("#722c38"), 2)

func draw_crab_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var angle := TAU * i / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
