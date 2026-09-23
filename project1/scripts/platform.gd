extends StaticBody2D

var platform_size := Vector2(400, 100)
var is_raised := false

func setup(new_size: Vector2, raised := false) -> void:
	platform_size = new_size
	is_raised = raised
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = platform_size
	shape.shape = rectangle
	add_child(shape)
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(-platform_size / 2.0, platform_size)
	draw_rect(rect, Color("#153f4a"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, 16)), Color("#d2a45e"))
	draw_rect(Rect2(rect.position + Vector2(0, 13), Vector2(rect.size.x, 7)), Color("#6dbb75"))
	for x in range(int(rect.position.x) + 18, int(rect.end.x), 54):
		draw_circle(Vector2(x, rect.position.y + 38 + int(x / 7.0) % 26), 6, Color("#245b5d"))
	if is_raised:
		for x in range(int(rect.position.x) + 16, int(rect.end.x), 38):
			var base := Vector2(x, rect.position.y)
			draw_line(base, base + Vector2(sin(x) * 8, -32), Color("#2d9b68"), 6, true)
			draw_circle(base + Vector2(sin(x) * 8, -34), 6, Color("#63ce85"))
