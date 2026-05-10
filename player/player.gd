extends CharacterBody2D

const SPEED = 300.0
var half_size: Vector2
var interrogation_running: bool = true
var initial_camera_zoom: Vector2


@onready var actionable_finder: Area2D = $ActionableFinder

signal interrogation_started

func _ready() -> void:
	var shape := $CollisionShape2D.shape as RectangleShape2D
	half_size = shape.size / 2
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	initial_camera_zoom = get_viewport().get_camera_2d().zoom
	
func _on_dialogue_ended(resource: DialogueResource):
	interrogation_running = false
	var viewport = get_viewport()
	if viewport == null:
		return
	var camera = viewport.get_camera_2d()
	camera.set_zoom(initial_camera_zoom)
	camera.offset = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if interrogation_running:
			return
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			interrogation_started.emit()
			$AnimatedSprite2D.play("idle")
			interrogation_running = true
			actionables[0].action()
		return
		
func _physics_process(_delta: float) -> void:
	if interrogation_running:
		return
	var direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = direction.x < 0  # flip when moving left
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		$AnimatedSprite2D.play("idle")
	
	move_and_slide()
	clamp_to_world()

func clamp_to_world() -> void:
	var world_size = get_node("/root/Main").world_size
	global_position.x = clamp(global_position.x, half_size.x, world_size.x - half_size.x)
	global_position.y = clamp(global_position.y, half_size.y, world_size.y - half_size.y)
