extends CharacterBody2D

@export var speed : int = 400 

@export var direction : Vector2 = Vector2(1,0) # Normalized

@export var location : Vector2  = transform.origin

@export var is_client : bool = false

var moving_flag = false
func _ready() -> void:
	var position : Vector2 =  Vector2(0,0)
	$AnimatedSprite2D.play("walk_right")
	$AnimatedSprite2D.stop()

func process_inputs(inputsArray : Dictionary):
	
	var input_direction = Vector2(inputsArray["sidemove"], inputsArray["upmove"])
	velocity = input_direction * speed
	
	if (input_direction == Vector2(0,0)):
		velocity = Vector2()

func get_client_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	
	var normalizedVector = velocity.normalized()
	var buttons = []

	if (moving_flag):
		var inputs_object = {
			"time": Time.get_unix_time_from_system(),
			"sidemove": normalizedVector.x,
			"upmove": normalizedVector.y,
			"buttons": buttons,
		}
		$"../..".send_input(inputs_object)
	
	if (velocity != Vector2(0.0, 0.0)):
		moving_flag = true	
	if (velocity == Vector2(0.0, 0.0)):
		moving_flag = false	


func _physics_process(delta: float) -> void:
	if (is_client):
		get_client_input()
	move_and_slide()

func get_state() -> Dictionary:
	var state = {
		"time": Time.get_unix_time_from_system(),
		"x" :  position.x,
		"y" :  position.y,
		"speed": speed,
	}
	
	return state
	

func set_state(state : Dictionary):
	position = Vector2(state["x"], state["y"])
	speed = state["speed"]
	
	
	
func get_location() -> Vector2:
	return position
	
	
		
