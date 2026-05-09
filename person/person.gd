extends CharacterBody2D

var is_furry = true  # set this per NPC, true = actually a furry

func _ready() -> void:
	$Tail.play("tail1")
