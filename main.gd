extends Node

@export var person_scene:  PackedScene
var money
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var n = 5
	var face_images = get_face_images()
	for i in range(n):
		create_person(100*(i+1), 100*(i+1), face_images.pick_random())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_face_images() -> Array:
	# TODO: REPLACE THIS WITH REAL PPL FACE IMAGES
	return ["res://person/kirkhead.png"]

func get_persons_list() -> Array:
	# array will contain tuples
	# each tuple contains attributes
	return []

func create_person(x: float, y: float, face_image: String) -> void:
	# Create a new instance of the Person scene.
	var person = person_scene.instantiate()
	
	person.scale = Vector2(0.15, 0.15)

	# Set the person's position.
	person.position = Vector2(x, y)
	
	person.face_image = face_image
	
	# person.add_child(urthing)

	# Spawn the person by adding it to the Main scene.
	add_child(person)
