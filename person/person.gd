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
@export var accessories_equipped: Array = [0, 0, 0]  # ears, collar, tail respectively
@export var info: Array = ["pizza", "fish", "teacher"]  # favourite food, pet, occupation
@export var greeting: String = "Hello."

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var wait_timer: Timer = $WaitTimer

var home_position: Vector2
var movement_disabled: bool = false

func get_random_hsv() -> Color:
	# Hue: 0.0 to 1.0 (Full spectrum)
	# Saturation: 1.0 (Vibrant)
	# Value: 1.0 (Bright)
	return Color.from_hsv(randf(), 1.0, 1.0)
	
func make_grey() -> void:
	var body_parts = [$Tail, $Body, $Ears, $Head, $Clothes, $Collar, $Shoes, $Hoverboard]
	for part in body_parts:
		part.modulate = "#676767"
	
func make_angry() -> void:
	$Head.modulate = "#ff0000"
	$Body.modulate = "#ff0000"

func make_furry() -> void:
	var body_parts = [$Tail, $Body, $Ears, $Head, $Clothes, $Collar, $Shoes]
	for part in body_parts:
		part.hide()
	$FurryForm.show()
	
func furry_transformation() -> void:
	$Yogurt.show()
	var duration := 5.0
	var half := duration / 2.0
	var base_scale := scale
	var tween := create_tween().set_parallel(true)
	
	# First half - accelerating oscillation
	tween.tween_method(
		func(t: float): _oscillate_scale_x(t, base_scale.x),
		0.0, half, half
	)
	tween.tween_method(
		func(t: float): _oscillate_scale_y(t, base_scale.y),
		0.0, half, half
	)
	
	# At halfway point, transform and capture new furry scale
	tween.chain().tween_callback(func():
		$Yogurt.hide()
		make_furry()
		var furry_scale := scale  # capture scale AFTER make_furry
		
		var tween2 := create_tween().set_parallel(true)
		tween2.tween_method(
			func(t: float):
				var t_mirror := half - t
				var phase := 1.0 * t_mirror + 4.0 * t_mirror * t_mirror * 0.5
				scale.x = furry_scale.x * (1.0 + 3 * sin(phase * TAU) * t_mirror / 4),
			0.0, half, half
		)
		tween2.tween_method(
			func(t: float):
				var t_mirror := half - t
				var phase := 1.5 * t_mirror + 4.5 * t_mirror * t_mirror * 0.5
				scale.y = furry_scale.y * (1.0 + 0.5 * sin(phase * TAU) * t_mirror / 4),
			0.0, half, half
		)
	)
	# Set back to original
	tween.chain().tween_callback(func(): scale = base_scale)

func _oscillate_scale_x(t: float, base: float) -> void:
	var base_freq := 1
	var freq_accel := 4.0
	var amplitude := 3
	var phase := base_freq * t + freq_accel * t * t * 0.5
	scale.x = base * (1.0 + amplitude * sin(phase * TAU) * t / 4)

func _oscillate_scale_y(t: float, base: float) -> void:
	var base_freq := 1.5
	var freq_accel := 4.5
	var amplitude := 0.5
	var phase := base_freq * t + freq_accel * t * t * 0.5
	scale.y = base * (1.0 + amplitude * sin(phase * TAU) * t / 4)
	
func start_conversation():
	movement_disabled = true
	var target := $"/root/Main/Player"
	var distance := 200.0
	global_position = target.global_position + Vector2.LEFT * distance
	get_viewport().get_camera_2d().offset = Vector2.LEFT * distance / 2
	$"/root/Main/Player/AnimatedSprite2D".flip_h = true

func _ready() -> void:
	if accessories_equipped[0] != 0:
		$Ears.show()
	if accessories_equipped[1] != 0:
		if accessories_equipped[1] == 1:
			$Collar.play("collar1")
		else:
			$Collar.play("collar2")
		$Collar.show()
	if accessories_equipped[2] != 0:
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
	if movement_disabled:
		return
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
	if movement_disabled:
		return
	velocity = safe_velocity
	move_and_slide()
