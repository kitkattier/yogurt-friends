extends Node

@export var person_scene:  PackedScene
var money

@onready var timer: Timer = $Timer
@onready var hud: Hud = $Hud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var n = 5
	var face_images = get_face_images()
	for i in range(n):
		var this_face_image = face_images.pick_random()
		create_person(100*(i+1), 100*(i+1), this_face_image[0], this_face_image[1])
	timer.timeout.connect(_on_time_up)
	hud.update_money(0)  # initial value
	timer.start()


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

func create_person(x: float, y: float, person_name: String, face_image: String) -> void:
	# Create a new instance of the Person scene.
	var person = person_scene.instantiate()
	
	person.scale = Vector2(0.15, 0.15)

	# Set the person's position.
	person.position = Vector2(x, y)
	
	person.person_name = person_name
	person.face_image = face_image
	

	# Spawn the person by adding it to the Main scene.
	add_child(person)
