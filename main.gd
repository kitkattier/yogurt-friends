extends Node

@export var person_scene:  PackedScene
var money
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(5):
		create_person(100*(i+1), 100*(i+1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func create_person(x: float, y: float) -> void:
	# Create a new instance of the Person scene.
	var person = person_scene.instantiate()
	
	person.scale = Vector2(0.15, 0.15)

	# Set the person's position.
	person.position = Vector2(x, y)
	

	# Spawn the person by adding it to the Main scene.
	add_child(person)
