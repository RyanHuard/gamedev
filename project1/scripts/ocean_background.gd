extends Node2D

func _ready() -> void:
	z_index = -20
	queue_redraw()

func _draw() -> void:
	# Long level-wide gradient bands.
	draw_rect(Rect2(-1000, -200, 18000, 1000), Color("#06283c"))
	for i in range(12):
		var shade := Color("#0a6680").lerp(Color("#05283c"), float(i) / 11.0)
		draw_rect(Rect2(-1000, -100 + i * 70, 18000, 72), shade)
	# Distant light shafts and rock silhouettes.
	for x in range(-300, 16500, 1100):
		var beam := PackedVector2Array([Vector2(x, -100), Vector2(x + 240, -100), Vector2(x + 620, 720), Vector2(x + 360, 720)])
		draw_colored_polygon(beam, Color(0.2, 0.85, 0.92, 0.045))
	for x in range(-400, 16500, 520):
		var height := 70.0 + float((x * 17) % 120)
		draw_circle(Vector2(x, 660), height, Color("#083747"))
	# Far-away kelp creates depth without affecting gameplay.
	for x in range(100, 16000, 420):
		var h := 80.0 + float((x * 13) % 110)
		var points := PackedVector2Array()
		for j in range(8):
			points.append(Vector2(x + sin(j * 1.3 + x) * 13.0, 650 - j * h / 7.0))
		draw_polyline(points, Color(0.03, 0.36, 0.34, 0.55), 9.0, true)
