extends Node

@export var dialogue_resource: DialogueResource

var good_ending: bool

func start_ending_scene() -> void:
	good_ending = get_parent().money >= 3
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start", [self])
