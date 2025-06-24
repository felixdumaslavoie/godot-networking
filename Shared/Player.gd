extends CharacterBody2D
class_name Player

@export var speed : int = 400

@export var direction : Vector2 = Vector2(1,0) # Normalized

@export var is_client : bool = false
@export var is_server : bool = false

const LERP_RATE : float = 0.08

## Client 
var id : int = 0
var moving_flag = false
var client_inputs_buffer : Array = []
var client_processed_buffer : Array = []

var last_authoritative_time : float = 0


func _ready() -> void:
	var position : Vector2 =  Vector2(0,0)
	$AnimatedSprite2D.play("walk_right")
	$AnimatedSprite2D.stop()
	if (is_server == true):
		$AnimatedSprite2D.material = null

func process_world_update(worldUpdateArray : Dictionary):
	
	var movement_direction = Vector2(worldUpdateArray["sidemove"], worldUpdateArray["upmove"])
	
	direction =  Vector2(worldUpdateArray["viewangle_side"], worldUpdateArray["viewangle_up"])
	
	velocity = movement_direction * speed
	
	if (movement_direction == Vector2(0,0)):
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
			"viewangle_side": direction.normalized().x,
			"viewangle_up": direction.normalized().y,
			"buttons": buttons,
		}
		$"../".send_input(inputs_object)
		client_inputs_buffer.push_back(inputs_object)
	
	if (velocity != Vector2(0.0, 0.0)):
		moving_flag = true
		direction = velocity.normalized()
	if (velocity == Vector2(0.0, 0.0)):
		moving_flag = false	


func client_prediction():
	if (client_inputs_buffer.size() > 0):
		var oldest_action = client_inputs_buffer.pop_back()
		client_processed_buffer.push_back(oldest_action)
		
		velocity = Vector2( oldest_action["sidemove"], oldest_action["upmove"]) * speed * speed 
		direction = Vector2(oldest_action["viewangle_side"], oldest_action["viewangle_up"])
	

func _physics_process(delta: float) -> void:
	if (is_client):
		get_client_input()
	move_and_slide()

func get_state() -> Dictionary:
	
	var state = {
		"x" :  position.x,
		"y" :  position.y,
		"viewangle_side": direction.x,
		"viewangle_up": direction.y,
		"buttons": [],
	}
	#print(state)
	
	return state
	
# Server reconciliation
func set_state(state : Dictionary):
	# Lerp authoritative corrections
	#print(state)
	
	
	var request_time = state["time"]
	
	for processed_input in client_processed_buffer:
		pass
		
		
		
	
	#position = lerp(position, Vector2(state["x"], state["y"]), LERP_RATE)
	#direction = Vector2(state["viewangle_side"], state["viewangle_up"])

	
func get_location() -> Vector2:
	return position
	
#	
## 
###
### Server code
##
#
func input_processing(oldest_input : Dictionary) :
	var input_direction = Vector2(oldest_input["sidemove"],oldest_input["upmove"] )
	velocity = input_direction * speed
	
	#get_tree().quit()
