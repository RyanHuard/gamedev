extends Node2D

var effect_type := "urchin"
var effect_radius := 80.0
var elapsed := 0.0
var duration := 0.38

func setup(type: String, radius: float) -> void:
	effect_type = type
	effect_radius = radius
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = 4
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= duration:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	if effect_type != "urchin":
		return
	var progress := clampf(elapsed / duration, 0.0, 1.0)
	var alpha := 1.0 - progress
	var radius := lerpf(10.0, effect_radius, ease(progress, -1.5))
	# Expanding water shockwave marking the full splash-damage area.
	draw_circle(Vector2.ZERO, radius, Color(0.48, 0.25, 0.68, 0.13 * alpha))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(0.78, 0.55, 0.94, 0.9 * alpha), 4.0)
	draw_arc(Vector2.ZERO, maxf(2.0, radius - 6.0), 0.0, TAU, 40, Color(0.30, 0.16, 0.42, 0.65 * alpha), 2.0)
	# Short spikes make the blast visually match the urchin projectile.
	for i in range(8):
		var direction := Vector2.RIGHT.rotated(TAU * i / 8.0)
		draw_line(direction * (radius - 3.0), direction * (radius + 8.0), Color(0.68, 0.38, 0.86, alpha), 3.0)
