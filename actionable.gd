extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func action() -> void:
	get_viewport().get_camera_2d().set_zoom(Vector2(3, 3))
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start, [owner])
