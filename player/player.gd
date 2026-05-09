extends CharacterBody2D

const SPEED = 300.0
var half_size: Vector2

func _ready() -> void:
	var shape := $CollisionShape2D.shape as RectangleShape2D
	half_size = shape.size / 2

func _physics_process(_delta: float) -> void:
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
