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
		create_person(x, y, this_face_image[0], this_face_image[1], accessories_equipped)
	timer.timeout.connect(_on_time_up)
	hud.update_money(0)  # initial value
	timer.start()

	fill_sand()
	scatter_props()
	add_border_walls()


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

func create_person(x: float, y: float, person_name: String, face_image: String, accessories_equipped: Array[bool]) -> void:
	# Create a new instance of the Person scene.
	var person = person_scene.instantiate()
	person.scale = Vector2(0.15, 0.15)
	person.position = Vector2(x, y)
	person.person_name = person_name
	person.face_image = face_image
	person.accessories_equipped = accessories_equipped

	# Spawn the person by adding it to the Main scene.
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
		"res://assets/beach_tree.png": 15,
		"res://assets/bird.png.png": 20,
		"res://assets/beach_stump.png": 15,
		"res://assets/beach_mushroom.png": 10,
		"res://assets/poop_bucket.png": 10,
	}
	
	for path in props:
		var texture = load(path)
		var count = props[path]
		for i in range(count):
			var body = StaticBody2D.new()
			var sprite = Sprite2D.new()
			var collision = CollisionShape2D.new()
			var shape = RectangleShape2D.new()
			
			sprite.texture = texture
			sprite.flip_h = randi() % 2 == 0
			
			var s = randf_range(0.8, 1.2)
			sprite.scale = Vector2(s, s)
			
			# Collision size based on texture size
			shape.size = texture.get_size() * s * 0.7  # 0.7 so collision is slightly smaller than sprite
			collision.shape = shape
			
			body.add_child(sprite)
			body.add_child(collision)
			body.z_index = 1
			body.position = Vector2(
				randf_range(150, world_size.x - 150),
				randf_range(150, world_size.y - 150)
			)
			add_child(body)
