extends CharacterBody2D

const SPEED = 300.0
var half_size: Vector2
@onready var actionable_finder: Area2D = $ActionableFinder

var interrogation_running: bool = false

signal interrogation_started

func _ready() -> void:
	var shape := $CollisionShape2D.shape as RectangleShape2D
	half_size = shape.size / 2
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
func _on_dialogue_ended(resource: DialogueResource):
	interrogation_running = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			interrogation_started.emit()
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
	clamp_to_viewport()

func clamp_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	global_position.x = clamp(global_position.x, half_size.x, viewport_size.x - half_size.x)
	global_position.y = clamp(global_position.y, half_size.y, viewport_size.y - half_size.y)
