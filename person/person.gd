extends Area2D

var is_furry = true  # set this per NPC, true = actually a furry

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play("normal")  # show normal human by default
	
func _on_body_entered(body: Node) -> void:
	print("something entered: ", body.name)
	if body.name == "Player":  # make sure your player node is named "Player"
		show_inspect_prompt()

func show_inspect_prompt() -> void:
	# For now just print, you'll replace this with real UI later
	print("Press E to inspect!")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inspect"):  # ui_accept is the E key by default
		inspect()

func inspect() -> void:
	# This is where you'll open your Friend/Foe UI
	# For now let's just transform them immediately as a test
	transform_to_furry()
	
func transform_to_furry() -> void:
	$AnimatedSprite2D.play("furry")  # swap to furry animation
