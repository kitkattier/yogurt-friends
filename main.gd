extends Node

@export var person_scene: PackedScene
var money
var world_size: Vector2

@onready var timer: Timer = $Timer
@onready var hud: Hud = $Hud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	world_size = viewport_size * 2

	# Everything starts at top left (0,0)
	$TileMap.position = Vector2.ZERO
	$Ocean.size = world_size + Vector2(700, 700)  # extend beyond world
	$Ocean.position = Vector2(-400, -400)  # shift it to cover negative area

	# Camera limits match world size
	$Player/Camera2D.limit_right = int(world_size.x) + 150
	$Player/Camera2D.limit_bottom = int(world_size.y) + 150
	$Player/Camera2D.limit_left = -150
	$Player/Camera2D.limit_top = -150

	# Player starts in center of world
	$Player.global_position = world_size / 2

	var n = 5
	var face_images = get_face_images()
	for i in range(n):
		var this_face_image = face_images.pick_random()
		# accessories_equipped corresponds to ears, collar, tail, respectively
		var accessories_equipped: Array[bool] = [true, false, true]
		var x = world_size.x / 2 + 100 * (i + 1)
		var y = world_size.y / 2 + 100 * (i + 1)
		create_person(this_face_image[0], this_face_image[1], accessories_equipped)
	timer.timeout.connect(_on_time_up)
	hud.update_money(0)  # initial value
	timer.start()
	
	$Truck.position = world_size / 2
	fill_sand()
	scatter_props()
	add_border_walls()
	setup_navigation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	hud.update_time(timer.time_left)

func get_face_images() -> Array:
	# TODO: REPLACE THIS WITH REAL PPL FACE IMAGES
	return [["Kirk", "res://person/kirkhead.png"],
	["Palm Beach Pete", "res://person/palmbeachpete.png"]]

func _on_time_up() -> void:
	print("Time's up!")

func get_persons_list() -> Array:
	# array will contain tuples
	# each tuple contains attributes
	return []

func create_person(person_name: String, face_image: String, accessories_equipped: Array[bool]) -> void:
	var person = person_scene.instantiate()
	person.scale = Vector2(0.15, 0.15)
	person.position = Vector2(
		randf_range(200, world_size.x - 200),
		randf_range(200, world_size.y - 200)
	)
	person.person_name = person_name
	person.face_image = face_image
	person.accessories_equipped = accessories_equipped
	add_child(person)

func add_border_walls() -> void:
	var walls = [
		[Vector2(world_size.x / 2, 0), Vector2(world_size.x, 20)],         # top
		[Vector2(world_size.x / 2, world_size.y), Vector2(world_size.x, 20)], # bottom
		[Vector2(0, world_size.y / 2), Vector2(20, world_size.y)],          # left
		[Vector2(world_size.x, world_size.y / 2), Vector2(20, world_size.y)] # right
	]
	for wall in walls:
		var b = StaticBody2D.new()
		var s = CollisionShape2D.new()
		var r = RectangleShape2D.new()
		r.size = wall[1]
		s.shape = r
		b.add_child(s)
		add_child(b)
		b.position = wall[0]

func fill_sand() -> void:
	var tm = $TileMap
	var tile_size = tm.tile_set.tile_size.x
	var world_tiles_x = int(world_size.x / tile_size)
	var world_tiles_y = int(world_size.y / tile_size)
	
	for x in range(0, world_tiles_x, 3):
		for y in range(0, world_tiles_y, 3):
			for tx in range(3):
				for ty in range(3):
					tm.set_cell(0, Vector2i(x + tx, y + ty), 0, Vector2i(tx, ty))

func scatter_props() -> void:
	var props = {
		"res://assets/beach_tree.png": 0.0015,
		"res://assets/bird.png.png": 0.002,
		"res://assets/beach_stump.png": 0.0015,
		"res://assets/beach_mushroom.png": 0.001,
		"res://assets/poop_bucket.png": 0.0010,
	}
	
	var van_pos = world_size / 2
	var van_clear_radius = 500.0
	
	for path in props:
		var texture = load(path)
		if texture == null:
			print("FAILED TO LOAD: ", path)
			continue
		
		var count = int(world_size.x * world_size.y * props[path] / 1000.0)
		
		for i in range(count):
			var pos: Vector2
			var attempts = 0
			while attempts < 10:
				pos = Vector2(
					randf_range(150, world_size.x - 150),
					randf_range(150, world_size.y - 150)
				)
				if pos.distance_to(van_pos) > van_clear_radius:
					break
				attempts += 1
			
			var body = StaticBody2D.new()
			body.collision_layer = 1
			body.collision_mask = 1
			
			var sprite = Sprite2D.new()
			sprite.texture = texture
			sprite.flip_h = randi() % 2 == 0
			var s = randf_range(0.8, 1.2)
			sprite.scale = Vector2(s, s)
			
			var collision = CollisionShape2D.new()
			var shape = RectangleShape2D.new()
			shape.size = texture.get_size() * s * 0.7
			collision.shape = shape
			
			var obstacle = NavigationObstacle2D.new()
			obstacle.radius = texture.get_size().x * s * 0.5
			
			obstacle.avoidance_enabled = true
			body.add_child(sprite)
			body.add_child(collision)
			body.add_child(obstacle)
			body.position = pos
			body.z_index = 1
			add_child(body)
			
func setup_navigation() -> void:
	var nav = NavigationRegion2D.new()
	var nav_poly = NavigationPolygon.new()
	
	var outline = PackedVector2Array([
		Vector2(150, 150),
		Vector2(world_size.x - 150, 150),
		Vector2(world_size.x - 150, world_size.y - 150),
		Vector2(150, world_size.y - 150)
	])
	
	nav_poly.add_outline(outline)
	nav_poly.make_polygons_from_outlines()
	nav.navigation_polygon = nav_poly
	add_child(nav)
