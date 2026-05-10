extends Node

@export var dialogue_resource: DialogueResource

var good_ending: bool

const EVIL = preload("res://ending/evil_sunset.png")

func _ready() -> void:
	good_ending = GameState.good_ending
	if not good_ending:
		$TextureRect.texture = EVIL
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start", [self])
