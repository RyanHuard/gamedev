extends Node2D

const EnemyScript = preload("res://scripts/td_enemy.gd")
const TowerScript = preload("res://scripts/td_tower.gd")
const ProjectileScript = preload("res://scripts/td_projectile.gd")
const ImpactEffectScript = preload("res://scripts/td_impact_effect.gd")
const CrabOperatorScript = preload("res://scripts/td_crab_operator.gd")
const GoldCoinTexture = preload("res://assets/ui/gold_coin.png")
const ShellShooterTexture = preload("res://assets/towers/shell_shooter_v2.png")
const SeaweedSnareTexture = preload("res://assets/towers/seaweed_snare.png")
const UrchinCannonTexture = preload("res://assets/towers/urchin_cannon.png")
const CoralReefTexture = preload("res://assets/objectives/coral_reef.png")
const STARTING_GOLD := 190
const STARTING_HEALTH := 15
const LEVEL_2_STARTING_GOLD := 280
const LEVEL_2_STARTING_HEALTH := 20
const LEVEL_3_STARTING_GOLD := 340
const LEVEL_3_STARTING_HEALTH := 25
const FINAL_LEVEL := 3
const PROGRESS_SAVE_PATH := "user://reefguard_progress.cfg"
const TESTING_UNLOCK_ALL_LEVELS := true
const TOP_BAR_HEIGHT := 64.0
const OUTER_REEF_POSITION := Vector2(1180, 600)
const MIDNIGHT_REEF_POSITION := Vector2(640, 385)
const SHIPWRECK_RECT := Rect2(600, 345, 150, 58)
const LEVEL_THREE_VENTS := [Vector2(315, 505), Vector2(685, 160), Vector2(970, 350)]
const FLOOR_RIPPLE_ORIGINS := [Vector2(55, 650), Vector2(70, 250), Vector2(160, 135), Vector2(175, 500), Vector2(285, 390), Vector2(320, 610), Vector2(405, 520), Vector2(445, 115), Vector2(535, 265), Vector2(575, 430), Vector2(650, 590), Vector2(720, 240), Vector2(790, 400), Vector2(875, 650), Vector2(900, 145), Vector2(965, 470), Vector2(1035, 275), Vector2(1080, 665), Vector2(1160, 555), Vector2(1180, 360)]
const FLOOR_SHELLS := [Vector2(65, 330), Vector2(115, 655), Vector2(145, 565), Vector2(205, 215), Vector2(300, 120), Vector2(385, 205), Vector2(430, 400), Vector2(505, 630), Vector2(610, 675), Vector2(690, 670), Vector2(735, 535), Vector2(790, 105), Vector2(850, 270), Vector2(940, 255), Vector2(975, 625), Vector2(1045, 555), Vector2(1115, 145), Vector2(1165, 690), Vector2(1220, 175), Vector2(1240, 475)]
const WATER_PARTICLE_SEEDS := [Vector2(25, 215), Vector2(35, 120), Vector2(60, 625), Vector2(90, 520), Vector2(120, 250), Vector2(145, 360), Vector2(175, 665), Vector2(205, 205), Vector2(225, 455), Vector2(245, 590), Vector2(275, 135), Vector2(305, 435), Vector2(330, 555), Vector2(360, 275), Vector2(395, 185), Vector2(425, 650), Vector2(455, 375), Vector2(480, 505), Vector2(510, 225), Vector2(535, 335), Vector2(565, 675), Vector2(590, 150), Vector2(620, 550), Vector2(650, 455), Vector2(680, 295), Vector2(710, 620), Vector2(735, 110), Vector2(765, 195), Vector2(795, 485), Vector2(825, 335), Vector2(850, 570), Vector2(875, 675), Vector2(905, 235), Vector2(930, 535), Vector2(960, 115), Vector2(985, 355), Vector2(1010, 665), Vector2(1040, 175), Vector2(1065, 465), Vector2(1090, 605), Vector2(1120, 290), Vector2(1145, 420), Vector2(1170, 135), Vector2(1195, 265), Vector2(1215, 515), Vector2(1240, 650), Vector2(1255, 350), Vector2(1270, 105)]

var level_one_path := PackedVector2Array([
	Vector2(-40, 160), Vector2(220, 160), Vector2(220, 340),
	Vector2(520, 340), Vector2(520, 150), Vector2(820, 150),
	Vector2(820, 500), Vector2(1090, 500), Vector2(1180, 600)
])
var level_two_paths: Array[PackedVector2Array] = [
	PackedVector2Array([
		Vector2(-40, 150), Vector2(300, 150), Vector2(300, 280),
		Vector2(650, 280), Vector2(650, 130), Vector2(900, 130),
		Vector2(900, 340), Vector2(1060, 340), Vector2(1180, 600)
	]),
	PackedVector2Array([
		Vector2(-40, 580), Vector2(250, 580), Vector2(250, 440),
		Vector2(520, 440), Vector2(520, 590), Vector2(820, 590),
		Vector2(820, 440), Vector2(1040, 440), Vector2(1180, 600)
	])
]
var level_three_paths: Array[PackedVector2Array] = [
	PackedVector2Array([
		Vector2(-40, 360), Vector2(190, 360), Vector2(190, 220),
		Vector2(430, 220), Vector2(430, 385), MIDNIGHT_REEF_POSITION
	]),
	PackedVector2Array([
		Vector2(1120, 60), Vector2(1120, 175), Vector2(860, 175),
		Vector2(860, 290), Vector2(720, 290), MIDNIGHT_REEF_POSITION
	]),
	PackedVector2Array([
		Vector2(1320, 610), Vector2(1040, 610), Vector2(1040, 515),
		Vector2(815, 515), Vector2(815, 420), MIDNIGHT_REEF_POSITION
	])
]
var level_one_waves := [
	[{"kind":"plankton", "count":7, "hp":28.0, "speed":68.0, "reward":10}],
	[{"kind":"plankton", "count":10, "hp":38.0, "speed":76.0, "reward":10}],
	[{"kind":"plankton", "count":10, "hp":48.0, "speed":72.0, "reward":11}, {"kind":"stingray", "count":3, "hp":90.0, "speed":48.0, "reward":17}],
	[{"kind":"plankton", "count":8, "hp":58.0, "speed":82.0, "reward":11}, {"kind":"stingray", "count":5, "hp":115.0, "speed":51.0, "reward":18}],
	[{"kind":"plankton", "count":9, "hp":72.0, "speed":88.0, "reward":12}, {"kind":"stingray", "count":6, "hp":145.0, "speed":54.0, "reward":19}, {"kind":"sea_spider", "count":1, "hp":550.0, "speed":38.0, "reward":100}]
]
var level_two_waves := [
	[{"kind":"plankton", "count":6, "hp":58.0, "speed":82.0, "reward":11, "route":0}, {"kind":"plankton", "count":6, "hp":58.0, "speed":82.0, "reward":11, "route":1}],
	[{"kind":"stingray", "count":4, "hp":130.0, "speed":53.0, "reward":18, "route":0}, {"kind":"plankton", "count":10, "hp":68.0, "speed":92.0, "reward":12, "route":1}],
	[{"kind":"plankton", "count":7, "hp":82.0, "speed":96.0, "reward":12, "route":0}, {"kind":"stingray", "count":3, "hp":155.0, "speed":56.0, "reward":19, "route":0}, {"kind":"plankton", "count":7, "hp":82.0, "speed":96.0, "reward":12, "route":1}, {"kind":"stingray", "count":3, "hp":155.0, "speed":56.0, "reward":19, "route":1}],
	[{"kind":"plankton", "count":8, "hp":98.0, "speed":102.0, "reward":13, "route":0}, {"kind":"stingray", "count":5, "hp":190.0, "speed":59.0, "reward":20, "route":0}, {"kind":"plankton", "count":8, "hp":98.0, "speed":102.0, "reward":13, "route":1}, {"kind":"stingray", "count":5, "hp":190.0, "speed":59.0, "reward":20, "route":1}],
	[{"kind":"plankton", "count":8, "hp":115.0, "speed":106.0, "reward":14, "route":0}, {"kind":"sea_spider", "count":1, "hp":700.0, "speed":40.0, "reward":110, "route":0}, {"kind":"plankton", "count":8, "hp":115.0, "speed":106.0, "reward":14, "route":1}, {"kind":"sea_spider", "count":1, "hp":700.0, "speed":40.0, "reward":110, "route":1}]
]
var level_three_waves := [
	[{"kind":"plankton", "count":10, "hp":105.0, "speed":108.0, "reward":13, "route":0}, {"kind":"stingray", "count":3, "hp":190.0, "speed":60.0, "reward":20, "route":0}],
	[{"kind":"plankton", "count":8, "hp":120.0, "speed":112.0, "reward":14, "route":1}, {"kind":"stingray", "count":6, "hp":215.0, "speed":63.0, "reward":21, "route":1}],
	[{"kind":"plankton", "count":9, "hp":130.0, "speed":116.0, "reward":15, "route":0}, {"kind":"stingray", "count":4, "hp":235.0, "speed":65.0, "reward":22, "route":0}, {"kind":"plankton", "count":9, "hp":130.0, "speed":116.0, "reward":15, "route":2}, {"kind":"stingray", "count":4, "hp":235.0, "speed":65.0, "reward":22, "route":2}],
	[{"kind":"plankton", "count":6, "hp":145.0, "speed":120.0, "reward":16, "route":0}, {"kind":"sea_spider", "count":1, "hp":850.0, "speed":43.0, "reward":120, "route":0}, {"kind":"plankton", "count":6, "hp":145.0, "speed":120.0, "reward":16, "route":1}, {"kind":"sea_spider", "count":1, "hp":850.0, "speed":43.0, "reward":120, "route":1}, {"kind":"plankton", "count":6, "hp":145.0, "speed":120.0, "reward":16, "route":2}, {"kind":"sea_spider", "count":1, "hp":850.0, "speed":43.0, "reward":120, "route":2}]
]
var level_three_wave_names := ["WEST CURRENT", "NORTHEAST CURRENT", "WEST + SOUTHEAST", "ALL THREE CURRENTS"]
var active_paths: Array[PackedVector2Array] = []
var waves: Array = []

var enemies: Array[Node2D] = []
var towers: Array[Node2D] = []
var gold := STARTING_GOLD
var reef_health := STARTING_HEALTH
var wave_index := 0
var wave_active := false
var spawn_queue: Array[Dictionary] = []
var spawn_clock := 0.0
var unlocked_towers := 1
var selected_type := "shell"
var selected_tower: Node2D
var dragging_type := ""
var drag_position := Vector2.ZERO
var drag_valid := false
var game_over := false
var level_complete := false
var current_level := 1
var highest_unlocked_level := 1
var coral_reef_position := OUTER_REEF_POSITION
var seen_enemy_tips := {}
var audio_player: AudioStreamPlayer
var tower_sounds := {}
var enemy_death_sound: AudioStreamWAV
var seaweed_impact_sound: AudioStreamWAV
var gold_label: Label
var health_label: Label
var wave_label: Label
var status_label: Label
var build_menu: ColorRect
var tower_buttons: Array[Button] = []
var tower_menu_rows: Array[HBoxContainer] = []
var tower_name_labels: Array[Label] = []
var tower_blurb_label: Label
var level_select_menu: ColorRect
var level_buttons: Array[Button] = []
var upgrade_menu: Panel
var upgrade_title_label: Label
var upgrade_option_buttons: Array[Button] = []
var upgrade_name_labels: Array[Label] = []
var upgrade_rank_labels: Array[Label] = []
var upgrade_description_labels: Array[Label] = []
var upgrade_cost_labels: Array[Label] = []
var status_panel: Panel
var tutorial_panel: ColorRect
var tutorial_label: Label
var tutorial_upgrade_done := false
var status_message_token := 0
var crab_operator: Node2D
var ocean_texture_time := 0.0

func _ready() -> void:
	active_paths = [level_one_path]
	waves = level_one_waves
	load_progress()
	build_hud()
	build_audio()
	build_level_select()
	queue_redraw()
	show_status("Choose a level to begin", 999.0)

func _draw() -> void:
	# Intentionally plain prototype art.
	var ocean_color := Color("#052e58") if current_level == 3 else Color("#087ca7")
	draw_rect(Rect2(0, 0, 1280, 720), ocean_color)
	draw_floor_ripples_and_shells()
	var preview_routes: Array[int] = []
	if current_level == 3 and not wave_active and wave_index < waves.size():
		for group in waves[wave_index]:
			var route_index := int(group.get("route", 0))
			if not preview_routes.has(route_index): preview_routes.append(route_index)
	for route_index in range(active_paths.size()):
		var route := active_paths[route_index]
		draw_polyline(route, Color("#07506f"), 86.0, false)
		draw_polyline(route, Color("#d1b878"), 68.0, false)
		draw_track_texture(route, route_index)
		if preview_routes.has(route_index):
			draw_polyline(route, Color("#7deaff"), 6.0, false)
	if current_level == 2:
		# Simple shipwreck obstacle separating the two currents.
		draw_rect(SHIPWRECK_RECT, Color("#422f2a"))
		draw_rect(Rect2(SHIPWRECK_RECT.position + Vector2(10, 9), Vector2(126, 34)), Color("#80563e"))
		draw_line(Vector2(672, 345), Vector2(672, 306), Color("#3a2927"), 7.0)
		draw_polygon(PackedVector2Array([Vector2(675, 310), Vector2(722, 327), Vector2(675, 327)]), PackedColorArray([Color("#b68a58")]))
	elif current_level == 3:
		for vent in LEVEL_THREE_VENTS:
			draw_circle(vent, 43.0, Color("#14243b"))
			draw_circle(vent, 31.0, Color("#342c3c"))
			draw_line(vent + Vector2(-21, 9), vent + Vector2(-5, -8), Color("#ff7438"), 5.0)
			draw_line(vent + Vector2(-5, -8), vent + Vector2(9, 6), Color("#ffb347"), 4.0)
			draw_line(vent + Vector2(9, 6), vent + Vector2(23, -10), Color("#ff7438"), 5.0)
	draw_water_particles()
	# Protected coral reef objective.
	draw_texture_rect(CoralReefTexture, Rect2(coral_reef_position - Vector2(56, 56), Vector2(112, 112)), false)
	draw_string(ThemeDB.fallback_font, coral_reef_position + Vector2(-48, 70), "CORAL REEF", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	if dragging_type != "":
		var info := TowerScript.get_tower_info(dragging_type)
		var preview_color := Color(0.3, 1.0, 0.45, 0.22) if drag_valid else Color(1.0, 0.25, 0.25, 0.22)
		var outline_color := Color("#67ef85") if drag_valid else Color("#ff5b5b")
		draw_circle(drag_position, info.range, preview_color)
		draw_arc(drag_position, info.range, 0, TAU, 64, outline_color, 2.0)
		draw_texture_rect(get_tower_texture(dragging_type), Rect2(drag_position - Vector2(32, 32), Vector2(64, 64)), false)
		draw_rect(Rect2(drag_position - Vector2(25, 25), Vector2(50, 50)), outline_color, false, 2.0)

func draw_floor_ripples_and_shells() -> void:
	# Small parallel wave marks resemble ripples pressed into seafloor sand.
	for group_index in range(FLOOR_RIPPLE_ORIGINS.size()):
		var origin: Vector2 = FLOOR_RIPPLE_ORIGINS[group_index]
		for row in range(3):
			var points := PackedVector2Array()
			for point_index in range(7):
				points.append(origin + Vector2(point_index * 11.0, row * 9.0 + sin(point_index * 1.35 + group_index) * 3.0))
			draw_polyline(points, Color(0.55, 0.86, 0.85, 0.20), 2.0)
	# A handful of compact shells add recognizable ocean-floor detail.
	for i in range(FLOOR_SHELLS.size()):
		var shell: Vector2 = FLOOR_SHELLS[i]
		var shell_color := Color(0.95, 0.78, 0.52, 0.72)
		draw_arc(shell, 9.0, PI, TAU, 10, shell_color, 3.0)
		draw_line(shell + Vector2(-9, 0), shell + Vector2(9, 0), shell_color, 2.0)
		for rib in range(3):
			var x := -5.0 + rib * 5.0
			draw_line(shell + Vector2(0, 1), shell + Vector2(x, -7), Color(0.78, 0.55, 0.36, 0.64), 1.5)

func draw_track_texture(route: PackedVector2Array, route_index: int) -> void:
	# Alternating sand grains follow the route while staying inside its darker border.
	var grain_index := route_index * 3
	for segment_index in range(route.size() - 1):
		var start := route[segment_index]
		var finish := route[segment_index + 1]
		var segment_length := start.distance_to(finish)
		var direction := start.direction_to(finish)
		var normal := direction.orthogonal()
		var steps := maxi(1, int(segment_length / 20.0))
		for step in range(steps):
			var progress := (step + 0.5) / float(steps)
			var offset := normal * float((grain_index % 3) - 1) * 14.0
			var grain_position := start.lerp(finish, progress) + offset
			var grain_color := Color(0.48, 0.37, 0.20, 0.34) if grain_index % 2 == 0 else Color(1.0, 0.91, 0.67, 0.38)
			draw_rect(Rect2(grain_position - Vector2(3, 2), Vector2(6, 4)), grain_color)
			if grain_index % 4 == 0:
				draw_line(grain_position + Vector2(-7, 7), grain_position + Vector2(7, 7), Color(0.55, 0.42, 0.25, 0.24), 2.0)
			grain_index += 1

func draw_water_particles() -> void:
	for i in range(WATER_PARTICLE_SEEDS.size()):
		var seed: Vector2 = WATER_PARTICLE_SEEDS[i]
		var particle := Vector2(
			fmod(seed.x + ocean_texture_time * (10.0 + i % 3 * 2.0), 1320.0) - 20.0,
			70.0 + fmod(seed.y - 70.0 - ocean_texture_time * (4.0 + i % 2 * 1.5) + 650.0, 650.0)
		)
		var particle_size := 2.0 if i % 3 else 3.0
		draw_rect(Rect2(particle, Vector2(particle_size, particle_size)), Color(0.72, 0.94, 0.94, 0.34))
func build_hud() -> void:
	var bar := ColorRect.new()
	bar.position = Vector2.ZERO
	bar.size = Vector2(1280, TOP_BAR_HEIGHT)
	bar.color = Color("#06364d")
	add_child(bar)
	var gold_row := HBoxContainer.new()
	gold_row.position = Vector2(20, 10)
	gold_row.size = Vector2(190, 42)
	gold_row.add_theme_constant_override("separation", 2)
	add_child(gold_row)
	gold_label = Label.new()
	gold_label.text = "Gold: %d" % gold
	gold_label.add_theme_font_size_override("font_size", 19)
	gold_label.add_theme_color_override("font_color", Color.WHITE)
	gold_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var gold_coin := TextureRect.new()
	gold_coin.custom_minimum_size = Vector2(22, 22)
	gold_coin.texture = GoldCoinTexture
	gold_coin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	gold_coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gold_coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	gold_row.add_child(gold_label)
	gold_row.add_child(gold_coin)
	health_label = make_label(Vector2(225, 16), Vector2(260, 32), "", 19)
	wave_label = make_label(Vector2(500, 16), Vector2(330, 32), "", 19)
	add_child(health_label)
	add_child(wave_label)
	var build_button := Button.new()
	build_button.position = Vector2(1000, 11)
	build_button.size = Vector2(120, 42)
	build_button.text = "BUILD"
	build_button.add_theme_font_size_override("font_size", 17)
	build_button.pressed.connect(toggle_build_menu)
	add_child(build_button)
	var wave_button := Button.new()
	wave_button.position = Vector2(1130, 11)
	wave_button.size = Vector2(130, 42)
	wave_button.text = "START WAVE"
	wave_button.add_theme_font_size_override("font_size", 15)
	wave_button.pressed.connect(start_next_wave)
	add_child(wave_button)
	build_tower_menu()
	build_upgrade_menu()
	build_tutorial_panel()
	status_panel = Panel.new()
	status_panel.position = Vector2(250, 650)
	status_panel.size = Vector2(780, 54)
	status_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_panel.z_index = 30
	status_panel.add_theme_stylebox_override("panel", make_panel_style(Color(0.015, 0.15, 0.21, 0.94), Color("#57c7d9"), 2, 10))
	add_child(status_panel)
	status_label = make_label(Vector2(20, 7), Vector2(740, 40), "", 17)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_panel.add_child(status_label)
	update_hud()

func build_tutorial_panel() -> void:
	tutorial_panel = ColorRect.new()
	tutorial_panel.position = Vector2(350, 70)
	tutorial_panel.size = Vector2(580, 82)
	tutorial_panel.color = Color(0.02, 0.16, 0.23, 0.92)
	tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_panel.z_index = 12
	add_child(tutorial_panel)
	tutorial_label = make_label(Vector2(12, 6), Vector2(556, 70), "", 15)
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_panel.add_child(tutorial_label)
	set_tutorial_message("Open BUILD menu and place a Shell Shooter in the water.")

func set_tutorial_message(message: String) -> void:
	if tutorial_label: tutorial_label.text = message
	if status_panel: clear_status()

func build_upgrade_menu() -> void:
	upgrade_menu = Panel.new()
	upgrade_menu.position = Vector2(300, 155)
	upgrade_menu.size = Vector2(680, 405)
	upgrade_menu.add_theme_stylebox_override("panel", make_panel_style(Color("#062b42"), Color("#55bed0"), 3, 12))
	upgrade_menu.visible = false
	upgrade_menu.z_index = 40
	add_child(upgrade_menu)
	upgrade_title_label = make_label(Vector2(30, 18), Vector2(620, 38), "Choose an upgrade", 24)
	upgrade_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	upgrade_menu.add_child(upgrade_title_label)
	var hint := make_label(Vector2(30, 57), Vector2(620, 28), "Pick the trait you want this tower to specialize in.", 14)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color("#9ddde9"))
	upgrade_menu.add_child(hint)
	for i in range(2):
		var option_button := Button.new()
		option_button.position = Vector2(25 + i * 327, 100)
		option_button.size = Vector2(303, 225)
		option_button.text = ""
		option_button.add_theme_stylebox_override("normal", make_panel_style(Color("#0a3c52"), Color("#286c80"), 2, 9))
		option_button.add_theme_stylebox_override("hover", make_panel_style(Color("#10536a"), Color("#72d7e5"), 3, 9))
		option_button.add_theme_stylebox_override("pressed", make_panel_style(Color("#082f42"), Color("#f4cf5b"), 3, 9))
		option_button.add_theme_stylebox_override("disabled", make_panel_style(Color("#162f3a"), Color("#38535c"), 2, 9))
		option_button.pressed.connect(choose_upgrade.bind(i))
		upgrade_menu.add_child(option_button)
		upgrade_option_buttons.append(option_button)
		var icon := TextureRect.new()
		icon.position = Vector2(18, 17)
		icon.size = Vector2(54, 54)
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		option_button.add_child(icon)
		icon.set_meta("tower_icon", true)
		var name_label := make_label(Vector2(84, 14), Vector2(195, 30), "", 18)
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		option_button.add_child(name_label)
		upgrade_name_labels.append(name_label)
		var rank_label := make_label(Vector2(84, 44), Vector2(195, 24), "", 13)
		rank_label.add_theme_color_override("font_color", Color("#8fe3ee"))
		rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		option_button.add_child(rank_label)
		upgrade_rank_labels.append(rank_label)
		var description_label := make_label(Vector2(18, 88), Vector2(267, 67), "", 15)
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		option_button.add_child(description_label)
		upgrade_description_labels.append(description_label)
		var cost_row := HBoxContainer.new()
		cost_row.position = Vector2(108, 176)
		cost_row.size = Vector2(88, 30)
		cost_row.alignment = BoxContainer.ALIGNMENT_CENTER
		cost_row.add_theme_constant_override("separation", 4)
		cost_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		option_button.add_child(cost_row)
		var cost_label := Label.new()
		cost_label.add_theme_font_size_override("font_size", 18)
		cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cost_row.add_child(cost_label)
		upgrade_cost_labels.append(cost_label)
		var coin := TextureRect.new()
		coin.custom_minimum_size = Vector2(22, 22)
		coin.texture = GoldCoinTexture
		coin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cost_row.add_child(coin)
	var cancel_button := Button.new()
	cancel_button.position = Vector2(265, 344)
	cancel_button.size = Vector2(150, 42)
	cancel_button.text = "Back"
	cancel_button.add_theme_font_size_override("font_size", 16)
	cancel_button.pressed.connect(func(): upgrade_menu.visible = false)
	upgrade_menu.add_child(cancel_button)

func make_panel_style(background: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style

func build_level_select() -> void:
	level_select_menu = ColorRect.new()
	level_select_menu.position = Vector2.ZERO
	level_select_menu.size = Vector2(1280, 720)
	level_select_menu.color = Color(0.015, 0.10, 0.15, 0.82)
	level_select_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	level_select_menu.z_index = 100
	add_child(level_select_menu)
	var panel := ColorRect.new()
	panel.position = Vector2(390, 165)
	panel.size = Vector2(500, 380)
	panel.color = Color("#073047")
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	level_select_menu.add_child(panel)
	var title := make_label(Vector2(30, 24), Vector2(440, 44), "SELECT A LEVEL", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)
	var subtitle := make_label(Vector2(30, 66), Vector2(440, 34), "Choose a reef to defend", 16)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_color_override("font_color", Color("#9ddde9"))
	panel.add_child(subtitle)
	var level_one_button := Button.new()
	level_one_button.position = Vector2(55, 120)
	level_one_button.size = Vector2(390, 55)
	level_one_button.text = "Tutorial: Tidepool Reef"
	level_one_button.add_theme_font_size_override("font_size", 18)
	level_one_button.pressed.connect(choose_level.bind(1))
	panel.add_child(level_one_button)
	level_buttons.append(level_one_button)
	var level_two_button := Button.new()
	level_two_button.position = Vector2(55, 193)
	level_two_button.size = Vector2(390, 55)
	level_two_button.text = "Level 2: Shipwreck"
	level_two_button.add_theme_font_size_override("font_size", 18)
	level_two_button.pressed.connect(choose_level.bind(2))
	panel.add_child(level_two_button)
	level_buttons.append(level_two_button)
	var level_three_button := Button.new()
	level_three_button.position = Vector2(55, 266)
	level_three_button.size = Vector2(390, 55)
	level_three_button.text = "Level 3: Midnight Vent"
	level_three_button.add_theme_font_size_override("font_size", 18)
	level_three_button.pressed.connect(choose_level.bind(3))
	panel.add_child(level_three_button)
	level_buttons.append(level_three_button)
	update_level_buttons()

func choose_level(level_number: int) -> void:
	if level_number > highest_unlocked_level:
		return
	level_select_menu.visible = false
	start_level(level_number)

func update_level_buttons() -> void:
	var names := ["Tutorial: Tidepool Reef", "Level 2: Shipwreck", "Level 3: Midnight Vent"]
	for i in range(level_buttons.size()):
		var unlocked := i + 1 <= highest_unlocked_level
		level_buttons[i].disabled = not unlocked
		level_buttons[i].text = names[i] if unlocked else "%s  —  Locked" % names[i]
		level_buttons[i].tooltip_text = "" if unlocked else "Complete the previous level to unlock this reef."

func load_progress() -> void:
	if TESTING_UNLOCK_ALL_LEVELS:
		highest_unlocked_level = FINAL_LEVEL
		return
	var config := ConfigFile.new()
	if config.load(PROGRESS_SAVE_PATH) == OK:
		highest_unlocked_level = clampi(int(config.get_value("progress", "highest_unlocked_level", 1)), 1, FINAL_LEVEL)

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "highest_unlocked_level", highest_unlocked_level)
	config.save(PROGRESS_SAVE_PATH)

func build_tower_menu() -> void:
	build_menu = ColorRect.new()
	build_menu.position = Vector2(930, 70)
	build_menu.size = Vector2(330, 250)
	build_menu.color = Color("#073047")
	build_menu.visible = false
	build_menu.z_index = 20
	add_child(build_menu)
	var title := make_label(Vector2(15, 10), Vector2(300, 25), "DRAG A TOWER ONTO THE MAP", 14)
	build_menu.add_child(title)
	var types := ["shell", "seaweed", "urchin"]
	var textures := [ShellShooterTexture, SeaweedSnareTexture, UrchinCannonTexture]
	for i in range(types.size()):
		var type: String = types[i]
		var info := TowerScript.get_tower_info(type)
		var button := Button.new()
		button.position = Vector2(15, 43 + i * 46)
		button.size = Vector2(300, 38)
		button.text = ""
		button.add_theme_font_size_override("font_size", 15)
		button.button_down.connect(start_tower_drag.bind(type))
		button.mouse_entered.connect(show_tower_blurb.bind(type))
		button.mouse_exited.connect(clear_tower_blurb)
		build_menu.add_child(button)
		var row := HBoxContainer.new()
		row.position = Vector2(9, 3)
		row.size = Vector2(282, 32)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 7)
		button.add_child(row)
		var tower_icon := TextureRect.new()
		tower_icon.custom_minimum_size = Vector2(28, 28)
		tower_icon.texture = textures[i]
		tower_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tower_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tower_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tower_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(tower_icon)
		var name_label := Label.new()
		name_label.text = info.name.to_upper()
		name_label.add_theme_font_size_override("font_size", 14)
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var cost_row := HBoxContainer.new()
		cost_row.add_theme_constant_override("separation", 2)
		cost_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(cost_row)
		var cost_label := Label.new()
		cost_label.text = str(info.cost)
		cost_label.add_theme_font_size_override("font_size", 15)
		cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cost_row.add_child(cost_label)
		var coin := TextureRect.new()
		coin.custom_minimum_size = Vector2(20, 20)
		coin.texture = GoldCoinTexture
		coin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cost_row.add_child(coin)
		tower_buttons.append(button)
		tower_menu_rows.append(row)
		tower_name_labels.append(name_label)
	tower_blurb_label = make_label(Vector2(15, 185), Vector2(300, 52), "Hover over a tower to learn what it does.", 13)
	tower_blurb_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tower_blurb_label.add_theme_color_override("font_color", Color("#c9edf5"))
	build_menu.add_child(tower_blurb_label)
	update_tower_menu()

func show_tower_blurb(type: String) -> void:
	var info := TowerScript.get_tower_info(type)
	tower_blurb_label.text = info.description

func clear_tower_blurb() -> void:
	tower_blurb_label.text = "Hover over a tower to learn what it does."

func toggle_build_menu() -> void:
	if dragging_type != "": return
	upgrade_menu.visible = false
	build_menu.visible = not build_menu.visible

func update_tower_menu() -> void:
	if tower_buttons.is_empty(): return
	for i in range(tower_buttons.size()):
		var locked := i >= unlocked_towers
		# Keep locked rows interactive so their descriptions can still be inspected.
		tower_buttons[i].disabled = false
		tower_menu_rows[i].modulate = Color(1, 1, 1, 0.38) if locked else Color.WHITE
		var type: String = ["shell", "seaweed", "urchin"][i]
		var info := TowerScript.get_tower_info(type)
		tower_name_labels[i].text = info.name.to_upper() + (" (LOCKED)" if locked else "")

func make_label(pos: Vector2, size: Vector2, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = size
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	return label

func _input(event: InputEvent) -> void:
	if dragging_type == "": return
	if event is InputEventMouseMotion:
		drag_position = event.position
		drag_valid = is_valid_placement(drag_position)
		queue_redraw()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		finish_tower_drag()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_tower_drag()

func _unhandled_input(event: InputEvent) -> void:
	if level_select_menu.visible:
		return
	if upgrade_menu.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_1:
				choose_upgrade(0)
			elif event.keycode == KEY_2:
				choose_upgrade(1)
			elif event.keycode == KEY_ESCAPE or event.keycode == KEY_U:
				upgrade_menu.visible = false
		return
	if event.is_action_pressed("restart"):
		if current_level > 1:
			start_level(current_level)
		else:
			get_tree().reload_current_scene()
		return
	if game_over:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_instance_valid(crab_operator) and crab_operator.is_operating():
		crab_operator.fire_at(event.position)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1: start_tower_drag("shell")
		elif event.keycode == KEY_2: start_tower_drag("seaweed")
		elif event.keycode == KEY_3: start_tower_drag("urchin")
		elif event.keycode == KEY_U: upgrade_selected()
		elif event.keycode == KEY_X: sell_selected()
		elif event.keycode == KEY_SPACE: start_next_wave()
	if dragging_type == "" and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var clicked := find_tower_at(event.position)
		if clicked:
			set_selected_tower(clicked)
			return
		set_selected_tower(null)

func start_tower_drag(type: String) -> void:
	var index := ["shell", "seaweed", "urchin"].find(type)
	if index < 0 or index >= unlocked_towers:
		show_status("That tower is still locked", 2.0)
		return
	var info := TowerScript.get_tower_info(type)
	if gold < info.cost:
		show_status("Not enough gold for %s" % info.name, 2.0)
		return
	selected_type = type
	upgrade_menu.visible = false
	set_selected_tower(null)
	dragging_type = type
	drag_position = get_viewport().get_mouse_position()
	drag_valid = is_valid_placement(drag_position)
	build_menu.visible = false
	show_status("Release to build  •  Right-click to cancel", 4.0)
	queue_redraw()

func finish_tower_drag() -> void:
	if drag_valid: place_tower(drag_position, dragging_type)
	else: show_status("Towers need open water away from the enemy path", 2.0)
	dragging_type = ""
	drag_valid = false
	queue_redraw()

func cancel_tower_drag() -> void:
	dragging_type = ""
	drag_valid = false
	queue_redraw()

func is_valid_placement(point: Vector2) -> bool:
	if point.x < 30.0 or point.x > 1250.0 or point.y < TOP_BAR_HEIGHT + 30.0 or point.y > 685.0:
		return false
	if build_menu.visible and Rect2(build_menu.position, build_menu.size).has_point(point):
		return false
	if point.distance_to(coral_reef_position) < 95.0:
		return false
	if current_level == 2 and SHIPWRECK_RECT.grow(38.0).has_point(point):
		return false
	if current_level == 3:
		for vent in LEVEL_THREE_VENTS:
			if point.distance_to(vent) < 78.0:
				return false
	for route in active_paths:
		for i in range(route.size() - 1):
			var nearest := Geometry2D.get_closest_point_to_segment(point, route[i], route[i + 1])
			if point.distance_to(nearest) < 68.0:
				return false
	for tower in towers:
		if is_instance_valid(tower) and point.distance_to(tower.position) < 58.0:
			return false
	return true

func find_tower_at(point: Vector2) -> Node2D:
	for tower in towers:
		if is_instance_valid(tower) and point.distance_to(tower.position) <= 32.0:
			return tower
	return null

func place_tower(place_position: Vector2, type: String) -> void:
	var info := TowerScript.get_tower_info(type)
	if gold < info.cost:
		show_status("Not enough gold", 2.0)
		return
	gold -= info.cost
	var tower = TowerScript.new()
	tower.position = place_position
	tower.setup(type, self, -1)
	add_child(tower)
	towers.append(tower)
	set_selected_tower(tower)
	if current_level == 1:
		match type:
			"shell":
				if wave_index == 0: set_tutorial_message("Move with WASD. Stand near any tower and press E to operate it.")
			"seaweed": set_tutorial_message("Seaweed slows and wraps enemies. Shell and Urchin attacks deal +40% to wrapped targets. Start Wave 2.")
			"urchin": set_tutorial_message("Urchins damage groups and counter Plankton and armored Stingrays. Start Wave 3.")
	play_tone(510.0, 0.1, 0.12)
	update_hud()
	queue_redraw()

func on_tower_operated(_tower: Node2D) -> bool:
	if current_level == 1 and wave_index == 0:
		set_tutorial_message("Tower mounted. This gives 40% more damage, faster firing, and 8% extra range. Its 6 pips are your manual shots. Press SPACE to start Wave 1. Click Plankton inside range to fire. Press E to dismount.")
		return true
	return false

func on_operator_charge_empty(tower: Node2D) -> void:
	if is_instance_valid(crab_operator):
		crab_operator.exhaust_tower(tower)

func set_selected_tower(tower: Node2D) -> void:
	if is_instance_valid(selected_tower): selected_tower.set_selected(false)
	upgrade_menu.visible = false
	selected_tower = tower
	if is_instance_valid(selected_tower):
		selected_tower.set_selected(true)
		show_status(selected_tower.get_summary().capitalize() + "  •  [U] Upgrade  •  [X] Sell", 3.0)

func upgrade_selected() -> void:
	if not is_instance_valid(selected_tower):
		show_status("Select a tower first", 1.5)
		return
	if selected_tower.level >= 3:
		show_status("This tower is already at max level", 1.5)
		return
	build_menu.visible = false
	var cost: int = selected_tower.get_upgrade_cost()
	var options: Array[Dictionary] = TowerScript.get_upgrade_options(selected_tower.tower_type)
	var tower_name: String = TowerScript.get_tower_info(selected_tower.tower_type).name
	upgrade_title_label.text = "%s  •  Level %d → %d" % [tower_name, selected_tower.level, selected_tower.level + 1]
	for i in range(2):
		var rank: int = selected_tower.upgrade_a if i == 0 else selected_tower.upgrade_b
		upgrade_name_labels[i].text = options[i].name
		upgrade_rank_labels[i].text = "Level %d  →  %d" % [rank + 1, rank + 2]
		upgrade_description_labels[i].text = options[i].description
		upgrade_cost_labels[i].text = str(cost)
		upgrade_option_buttons[i].disabled = gold < cost
		for child in upgrade_option_buttons[i].get_children():
			if child is TextureRect and child.has_meta("tower_icon"):
				child.texture = get_tower_texture(selected_tower.tower_type)
	upgrade_menu.visible = true
	if gold < cost: show_status("You need more gold for this upgrade", 2.0)

func choose_upgrade(option: int) -> void:
	if not is_instance_valid(selected_tower) or selected_tower.level >= 3:
		upgrade_menu.visible = false
		return
	var cost: int = selected_tower.get_upgrade_cost()
	if gold < cost:
		show_status("You need more gold for this upgrade", 1.8)
		return
	gold -= cost
	selected_tower.upgrade(option)
	if current_level == 1:
		tutorial_upgrade_done = true
		set_tutorial_message("Upgrade complete. Press X to sell a selected tower for 70% back, or start Wave 4.")
	upgrade_menu.visible = false
	show_status(selected_tower.get_summary(), 2.0)
	update_hud()

func sell_selected() -> void:
	if not is_instance_valid(selected_tower): return
	upgrade_menu.visible = false
	if is_instance_valid(crab_operator) and crab_operator.operated_tower == selected_tower:
		crab_operator.release_tower()
	gold += selected_tower.get_refund()
	towers.erase(selected_tower)
	selected_tower.queue_free()
	selected_tower = null
	update_hud()
	queue_redraw()

func start_next_wave() -> void:
	if wave_active or wave_index >= waves.size() or game_over: return
	if wave_index == 0 and towers.is_empty():
		show_status("Build at least one Shell Shooter first", 2.5)
		return
	if current_level == 1 and wave_index == 0 and (not is_instance_valid(crab_operator) or not crab_operator.is_operating()):
		set_tutorial_message("Move with WASD. Stand near any tower and press E to operate it.")
		return
	if current_level == 1:
		if wave_index == 3 and not tutorial_upgrade_done:
			set_tutorial_message("Select any tower, press U, then choose one of its two upgrades.")
			return
	upgrade_menu.visible = false
	build_menu.visible = false
	wave_active = true
	spawn_queue.clear()
	var wave_description: String = level_three_wave_names[wave_index] if current_level == 3 else ""
	var wave_groups: Array = waves[wave_index]
	var largest_group := 0
	for group in wave_groups:
		largest_group = maxi(largest_group, group.count)
	# Interleave groups so multi-route levels pressure their entrances together.
	for i in range(largest_group):
		for group in wave_groups:
			if i < group.count:
				spawn_queue.append(group.duplicate())
	wave_index += 1
	spawn_clock = 0.05
	if current_level == 3:
		show_status("Incoming from the %s" % wave_description.capitalize(), 3.0)
	else:
		clear_status()
	update_hud()
	queue_redraw()

func _process(delta: float) -> void:
	ocean_texture_time += delta
	queue_redraw()
	if not wave_active or game_over: return
	if not spawn_queue.is_empty():
		spawn_clock -= delta
		if spawn_clock <= 0.0:
			spawn_enemy(spawn_queue.pop_front())
			spawn_clock = maxf(0.42, 0.82 - wave_index * 0.055)
	elif enemies.is_empty():
		finish_wave()

func spawn_enemy(data: Dictionary) -> void:
	var enemy = EnemyScript.new()
	var route_index := clampi(int(data.get("route", 0)), 0, active_paths.size() - 1)
	enemy.setup(active_paths[route_index], data)
	enemy.reached_goal.connect(on_enemy_reached_goal)
	enemy.defeated.connect(on_enemy_defeated)
	add_child(enemy)
	enemies.append(enemy)
	var kind: String = data.kind
	if not seen_enemy_tips.has(kind):
		seen_enemy_tips[kind] = true
		match kind:
			"plankton": show_status("Plankton  •  Urchin splash deals +35% damage", 3.5)
			"stingray": show_status("Stingray  •  Resists pearls, but is weak to Urchins", 3.5)
			"sea_spider": show_status("Sea Spider  •  Resists Seaweed slows", 3.5)

func spawn_projectile(type: String, origin: Vector2, target: Node2D, damage: float, tower_level: int, upgrade_a := 0, upgrade_b := 0) -> void:
	var projectile = ProjectileScript.new()
	projectile.add_to_group("level_transient")
	add_child(projectile)
	projectile.global_position = origin
	projectile.setup(type, target, self, damage, tower_level, upgrade_a, upgrade_b)

func spawn_impact_effect(type: String, effect_position: Vector2, radius: float) -> void:
	var effect = ImpactEffectScript.new()
	effect.add_to_group("level_transient")
	add_child(effect)
	effect.global_position = effect_position
	effect.setup(type, radius)

func on_enemy_reached_goal(enemy: Node2D, damage: int) -> void:
	enemies.erase(enemy)
	if is_instance_valid(enemy): enemy.queue_free()
	reef_health -= damage
	update_hud()
	if reef_health <= 0: end_game(false)

func on_enemy_defeated(enemy: Node2D, reward: int) -> void:
	enemies.erase(enemy)
	gold += reward
	play_sound(enemy_death_sound, -9.0)
	update_hud()

func finish_wave() -> void:
	wave_active = false
	var bonus := 25 + wave_index * 5
	gold += bonus
	if wave_index >= waves.size():
		update_hud()
		queue_redraw()
		if current_level == 1: set_tutorial_message("TUTORIAL COMPLETE: You used every tower, enemy counter, and the upgrade system.")
		end_game(true)
		return
	var message := "Current is calm  •  Press Space when ready"
	if current_level == 1 and wave_index == 1:
		unlocked_towers = 2
		set_tutorial_message("UNLOCKED: Seaweed Snare. Its vines slow enemies and set up bonus damage. Try it, or start Wave 2.")
	elif current_level == 1 and wave_index == 2:
		unlocked_towers = 3
		set_tutorial_message("UNLOCKED: Urchin Cannon. It damages groups and counters Plankton. Try it, or start Wave 3.")
	elif current_level == 1 and wave_index == 3:
		if tutorial_upgrade_done:
			set_tutorial_message("Press X to sell a selected tower for 70% back, or start Wave 4.")
		else:
			set_tutorial_message("Select a tower, press U, and choose one of its two upgrade paths before Wave 4.")
	elif current_level == 1 and wave_index == 4:
		set_tutorial_message("FINAL LESSON: A Giant Sea Spider is coming. Use upgraded damage towers for Wave 5.")
	elif current_level == 3:
		message = "Next attack: %s  •  Press Space when ready" % level_three_wave_names[wave_index].capitalize()
	update_tower_menu()
	if current_level == 1:
		clear_status()
	else:
		show_status(message, 5.0)
	update_hud()
	queue_redraw()

func get_target(origin: Vector2, range_value: float) -> Node2D:
	var best: Node2D
	var best_progress := -1.0
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var progress: float = enemy.get_progress_ratio()
		if origin.distance_to(enemy.position) <= range_value and progress > best_progress:
			best = enemy
			best_progress = progress
	return best

func get_target_near_point(point: Vector2, tower_position: Vector2, range_value: float) -> Node2D:
	var best: Node2D
	var closest_to_click := 72.0
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.dead:
			continue
		var click_distance: float = point.distance_to(enemy.position)
		if tower_position.distance_to(enemy.position) <= range_value and click_distance < closest_to_click:
			best = enemy
			closest_to_click = click_distance
	return best

func get_nearest_tower(point: Vector2, max_distance: float) -> Node2D:
	var nearest: Node2D
	var nearest_distance := max_distance
	for tower in towers:
		if not is_instance_valid(tower):
			continue
		var distance := point.distance_to(tower.position)
		if distance <= nearest_distance:
			nearest = tower
			nearest_distance = distance
	return nearest

func get_enemies_near(origin: Vector2, radius: float) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for enemy in enemies:
		if is_instance_valid(enemy) and origin.distance_to(enemy.position) <= radius: result.append(enemy)
	return result

func tower_fired(type: String) -> void:
	if not tower_sounds.has(type): return
	var volume := -9.0 if type == "shell" else (-9.0 if type == "seaweed" else -7.0)
	play_sound(tower_sounds[type], volume)

func projectile_impact_sound(type: String) -> void:
	if type == "seaweed": play_sound(seaweed_impact_sound, -8.0)

func play_sound(stream: AudioStream, volume_db: float) -> void:
	if stream == null: return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.add_to_group("level_transient")
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func get_tower_texture(type: String) -> Texture2D:
	match type:
		"seaweed": return SeaweedSnareTexture
		"urchin": return UrchinCannonTexture
		_: return ShellShooterTexture

func end_game(won: bool) -> void:
	game_over = true
	wave_active = false
	upgrade_menu.visible = false
	build_menu.visible = false
	if won and current_level < FINAL_LEVEL:
		level_complete = true
		highest_unlocked_level = maxi(highest_unlocked_level, current_level + 1)
		save_progress()
		update_level_buttons()
		show_status("Coral reef defended  •  Level %d complete" % current_level, 999.0)
	elif won:
		show_status("Midnight Vent secured  •  All three levels complete", 999.0)
	else:
		show_status("The coral reef was lost  •  Choose a level to try again", 999.0)
	level_select_menu.visible = true

func start_level(level_number: int) -> void:
	for enemy in enemies:
		if is_instance_valid(enemy): enemy.queue_free()
	for tower in towers:
		if is_instance_valid(tower): tower.queue_free()
	for transient in get_tree().get_nodes_in_group("level_transient"):
		if is_instance_valid(transient): transient.queue_free()
	enemies.clear()
	towers.clear()
	spawn_queue.clear()
	seen_enemy_tips.clear()
	selected_tower = null
	crab_operator = null
	dragging_type = ""
	drag_valid = false
	wave_active = false
	game_over = false
	level_complete = false
	tutorial_upgrade_done = false
	wave_index = 0
	current_level = clampi(level_number, 1, FINAL_LEVEL)
	build_menu.visible = false
	upgrade_menu.visible = false
	if current_level == 3:
		active_paths = level_three_paths
		waves = level_three_waves
		coral_reef_position = MIDNIGHT_REEF_POSITION
		gold = LEVEL_3_STARTING_GOLD
		reef_health = LEVEL_3_STARTING_HEALTH
		unlocked_towers = 3
	elif current_level == 2:
		active_paths = level_two_paths
		waves = level_two_waves
		coral_reef_position = OUTER_REEF_POSITION
		gold = LEVEL_2_STARTING_GOLD
		reef_health = LEVEL_2_STARTING_HEALTH
		unlocked_towers = 3
	else:
		active_paths = [level_one_path]
		waves = level_one_waves
		coral_reef_position = OUTER_REEF_POSITION
		gold = STARTING_GOLD
		reef_health = STARTING_HEALTH
		unlocked_towers = 1
	update_tower_menu()
	update_hud()
	spawn_crab_operator()
	queue_redraw()
	tutorial_panel.visible = current_level == 1
	if current_level == 3:
		show_status("The first attack comes from the west current", 6.0)
	elif current_level == 2:
		show_status("Enemies approach along two separate routes", 6.0)
	else:
		set_tutorial_message("Open BUILD menu and place a Shell Shooter in the water.")
		clear_status()

func spawn_crab_operator() -> void:
	crab_operator = CrabOperatorScript.new()
	crab_operator.add_to_group("level_transient")
	add_child(crab_operator)
	crab_operator.setup(self, Vector2(640, 610))

func update_hud() -> void:
	if not gold_label: return
	gold_label.text = "Gold: %d" % gold
	health_label.text = "CORAL REEF: %d" % maxi(reef_health, 0)
	wave_label.text = "LEVEL: %d  |  WAVE: %d/%d" % [current_level, wave_index, waves.size()]

func show_status(message: String, duration: float) -> void:
	status_label.text = message
	status_panel.visible = true
	status_message_token += 1
	var token := status_message_token
	if duration < 900.0:
		get_tree().create_timer(duration).timeout.connect(func():
			if is_instance_valid(status_label) and status_message_token == token:
				status_label.text = ""
				status_panel.visible = false
		)

func clear_status() -> void:
	status_message_token += 1
	status_label.text = ""
	status_panel.visible = false

func build_audio() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	tower_sounds = {
		"shell": make_tower_sound("shell"),
		"seaweed": make_tower_sound("seaweed"),
		"urchin": make_tower_sound("urchin")
	}
	enemy_death_sound = make_enemy_death_sound()
	seaweed_impact_sound = make_seaweed_impact_sound()

func make_tower_sound(type: String) -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.12
	if type == "seaweed": duration = 0.11
	elif type == "urchin": duration = 0.20
	var frame_count := int(mix_rate * duration)
	var sound_data := PackedByteArray()
	sound_data.resize(frame_count * 2)
	var smoothed_noise := 0.0
	for i in range(frame_count):
		var progress := float(i) / frame_count
		var time := float(i) / mix_rate
		var noise_seed: float = sin(float(i) * 12.9898 + 2.41) * 43758.5453
		var noise: float = (noise_seed - floor(noise_seed)) * 2.0 - 1.0
		smoothed_noise = lerpf(smoothed_noise, noise, 0.16)
		var attack := minf(time / 0.002, 1.0)
		var envelope := attack * pow(1.0 - progress, 2.0)
		var sample := 0.0
		if type == "shell":
			# Two damped shell taps followed by a quiet underwater bubble tail.
			var first_snap := exp(-time * 72.0)
			var second_snap: float = exp(-(time - 0.018) * 88.0) if time >= 0.018 else 0.0
			var bubble_frequency := 185.0 - progress * 85.0
			sample = noise * first_snap * 0.34 + sin(TAU * 360.0 * time) * first_snap * 0.32
			sample += smoothed_noise * second_snap * 0.24 + sin(TAU * 245.0 * time) * second_snap * 0.22
			sample += sin(TAU * bubble_frequency * time) * pow(1.0 - progress, 3.0) * 0.13
			envelope = attack
		elif type == "seaweed":
			# Launch is only a light rush of water; the slime sound belongs on impact.
			var swish_shape := sin(PI * progress)
			sample = smoothed_noise * swish_shape * 0.70
			sample += sin(TAU * (170.0 - progress * 55.0) * time) * swish_shape * 0.12
			envelope = attack * pow(1.0 - progress, 0.8)
		else:
			# Muffled rock impact with a gritty attack, avoiding a clean laser-like tone.
			var thud := exp(-time * 18.0)
			sample = sin(TAU * 82.0 * time) * thud * 0.66
			sample += smoothed_noise * exp(-time * 35.0) * 0.48
			sample += sin(TAU * 47.0 * time) * thud * 0.18
			envelope = attack
		var value := int(clampf(sample * envelope, -1.0, 1.0) * 32767.0)
		sound_data.encode_s16(i * 2, value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = sound_data
	return stream

func make_seaweed_impact_sound() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.17
	var frame_count := int(mix_rate * duration)
	var sound_data := PackedByteArray()
	sound_data.resize(frame_count * 2)
	var smoothed_noise := 0.0
	for i in range(frame_count):
		var progress := float(i) / frame_count
		var time := float(i) / mix_rate
		var noise_seed: float = sin(float(i) * 9.731 + 4.11) * 31741.781
		var noise: float = (noise_seed - floor(noise_seed)) * 2.0 - 1.0
		smoothed_noise = lerpf(smoothed_noise, noise, 0.13)
		var sticky_shape := sin(PI * progress) * pow(1.0 - progress, 0.35)
		var wobble_frequency := 118.0 + sin(TAU * 8.0 * time) * 34.0
		var sample := sin(TAU * wobble_frequency * time) * sticky_shape * 0.42
		sample += smoothed_noise * sticky_shape * 0.82
		if progress > 0.68:
			var release := (progress - 0.68) / 0.32
			sample += sin(TAU * (155.0 + release * 135.0) * time) * sin(PI * release) * 0.25
		var value := int(clampf(sample, -1.0, 1.0) * 32767.0)
		sound_data.encode_s16(i * 2, value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = sound_data
	return stream

func make_enemy_death_sound() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 0.16
	var frame_count := int(mix_rate * duration)
	var sound_data := PackedByteArray()
	sound_data.resize(frame_count * 2)
	for i in range(frame_count):
		var time := float(i) / mix_rate
		var sample := 0.0
		var bubble_starts := [0.0, 0.052, 0.104]
		var bubble_frequencies := [145.0, 185.0, 235.0]
		for bubble_index in range(3):
			var local_time: float = time - bubble_starts[bubble_index]
			var bubble_length := 0.048
			if local_time >= 0.0 and local_time < bubble_length:
				var bubble_progress := local_time / bubble_length
				var bubble_envelope := sin(PI * bubble_progress) * pow(1.0 - bubble_progress, 0.35)
				var frequency: float = bubble_frequencies[bubble_index] + bubble_progress * 155.0
				var bubble := sin(TAU * frequency * local_time) * 0.62
				bubble += sin(TAU * frequency * 0.52 * local_time) * 0.18
				var onset_noise := sin(float(i + bubble_index * 37) * 5.73) * exp(-local_time * 95.0) * 0.10
				sample += (bubble + onset_noise) * bubble_envelope
		var value := int(clampf(sample, -1.0, 1.0) * 32767.0)
		sound_data.encode_s16(i * 2, value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = sound_data
	return stream

func play_tone(frequency: float, duration: float, volume: float) -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = maxf(duration + 0.03, 0.1)
	audio_player.stream = generator
	audio_player.volume_db = linear_to_db(volume)
	audio_player.play()
	var playback := audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null: return
	var frames := int(generator.mix_rate * duration)
	for i in range(frames):
		var sample := sin(TAU * frequency * float(i) / generator.mix_rate) * (1.0 - float(i) / frames)
		playback.push_frame(Vector2(sample, sample))
