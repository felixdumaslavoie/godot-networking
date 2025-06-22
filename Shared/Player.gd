extends CharacterBody2D

@export var speed : int = 160000 

@export var direction : Vector2 = Vector2(1,0) # Normalized


func _ready() -> void:
	var position : Vector2 =  Vector2(0,0)

func process_inputs(inputsArray : Dictionary):
	var input_direction = Vector2(inputsArray["sidemove"], inputsArray["upmove"])
	velocity = input_direction * speed

func _physics_process(delta: float) -> void:
	move_and_slide()

func get_state() -> Dictionary:
	var state = {
		"time": Time.get_unix_time_from_system(),
		"position" :  position,
		"speed": speed,
	}
	
	return state
	
	
