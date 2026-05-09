extends CharacterBody2D

@export var speed: float = 40.0
@export var wander_radius: float = 200.0
@export var min_wait: float = 2.0
@export var max_wait: float = 10.0
@export var answers: Dictionary
@export var person_name: String = "Name"
@export var face_image: String = "res://person/placeholder_head.png"
@export var is_furry: bool = true  # set this per NPC, true = actually a furry
@export var questions_answered: Array[bool] = [false, false, false]
@export var guessed: bool = false
@export var correct_guess: bool = false
@export var accessories_equipped: Array[bool] = [false, false, false]  # ears, collar, tail respectively

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var wait_timer: Timer = $WaitTimer

var home_position: Vector2
var movement_disabled: bool = false

func get_random_hsv() -> Color:
	# Hue: 0.0 to 1.0 (Full spectrum)
	# Saturation: 1.0 (Vibrant)
	# Value: 1.0 (Bright)
	return Color.from_hsv(randf(), 1.0, 1.0)
	
func make_angry() -> void:
	$Head.modulate = "#ff0000"

func make_furry() -> void:
	var body_parts = [$Tail, $Body, $Ears, $Head, $Clothes, $Collar, $Shoes]
	for part in body_parts:
		part.hide()
	$FurryForm.show()

func _ready() -> void:
	if accessories_equipped[0]:
		$Ears.show()
	if accessories_equipped[1]:
		$Collar.show()
	if accessories_equipped[2]:
		$Tail.play("tail1")
		$Tail.show()
	if randf() < 0.5:
		$FurryForm.play("form1")
	else:
		$FurryForm.play("form2")
	$Hoverboard.play("moving")
	$Hoverboard.hide()
	$Head.texture = load(face_image)
	
	var colour = get_random_hsv()
	$Clothes.modulate = colour
	$FurryForm.modulate = colour
	home_position = global_position
	wait_timer.timeout.connect(_pick_new_target)
	agent.velocity_computed.connect(_on_velocity_computed)
	await get_tree().physics_frame
	_start_waiting()

func _start_waiting() -> void:
	velocity = Vector2.ZERO
	$Hoverboard.hide()
	wait_timer.start(randf_range(min_wait, max_wait))

func _pick_new_target() -> void:
	var random_offset := Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)
	agent.target_position = home_position + random_offset
	$Hoverboard.show()

func _physics_process(_delta: float) -> void:
	if movement_disabled:
		return

	if agent.is_navigation_finished():
		if wait_timer.is_stopped() and velocity != Vector2.ZERO:
			_start_waiting()
		return

	var next_pos := agent.get_next_path_position()
	var desired_velocity := (next_pos - global_position).normalized() * speed
	agent.velocity = desired_velocity

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
