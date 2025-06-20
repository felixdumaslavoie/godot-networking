extends CharacterBody2D


@export var speed = 400

@export var location : Vector2  = $".".transform.origin
	
func _ready() -> void:
	$AnimatedSprite2D.play("walk_right")
	$AnimatedSprite2D.stop()

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	if (velocity != Vector2(0.0, 0.0)):
		var inputs_object = {
			"x": velocity.x,
			"y": velocity.y
		}
		$"../..".send_input(inputs_object)
		

func _physics_process(delta):
	get_input()
	move_and_slide()
	
