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
	if (is_server != true):
		$AnimatedSprite2D.material = null
		

func client_prediction():
	if (client_inputs_buffer.size() > 0):
		
		var move = client_inputs_buffer.pop_back()
		#print(move["sidemove"])
	
		position += Vector2(move["sidemove"] ,move["upmove"])
		
		client_processed_buffer.push_back(move)

#server reconcialiation
func process_world_update(player_world_update : Dictionary):
	if (is_client):
		
		var authoritative_time : float = player_world_update["time"]
		
		for processed_input in client_processed_buffer:
			
			if (float(processed_input["time"]) < float(authoritative_time)):
				print(processed_input["time"])
			
			

			#position = lerp(position, Vector2(player_world_update["x"], player_world_update["y"]), LERP_RATE)
			#direction = Vector2(player_world_update["viewangle_side"], player_world_update["viewangle_up"])
		last_authoritative_time = authoritative_time
	#position = Vector2(player_world_update["x"], player_world_update["y"])

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
		client_inputs_buffer.push_back(inputs_object)
		
		$"..".send_input_to_server(inputs_object)
	
	if (velocity != Vector2(0.0, 0.0)):
		moving_flag = true
		direction = velocity.normalized()
	if (velocity == Vector2(0.0, 0.0)):
		moving_flag = false	




func _physics_process(delta: float) -> void:
	if (is_client):
		get_client_input()
		client_prediction()
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
	var heading_to = Vector2(oldest_input["viewangle_side"],oldest_input["viewangle_up"] )
	
	velocity = input_direction * speed
	direction = heading_to
	#get_tree().quit()
