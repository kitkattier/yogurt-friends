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

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var wait_timer: Timer = $WaitTimer

var home_position: Vector2

func _ready() -> void:
	$Tail.play("tail1")
	$Hoverboard.play("moving")
	$Hoverboard.hide()
	$Head.texture = load(face_image)
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
