extends CharacterBody2D
class_name Player

@export var speed : int = 400

@export var direction : Vector2 = Vector2(1,0) # Normalized

@export var is_client : bool = false
@export var is_server : bool = false

const LERP_RATE : float = 0.05

## Client 
var id : int = 0
var moving_flag = false
var client_inputs_buffer : Array = []
var client_processed_buffer : Array = []

var last_authoritative_time : float = 0.0

var last_processed_timestamp : float = 0.0

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
		
		move["y"] = position.y
		move["x"] = position.x
		#position += Vector2(move["sidemove"] ,move["upmove"])
		position = lerp(position, Vector2(position.x + move["sidemove"], position.y + move["upmove"]), LERP_RATE)
		
		last_processed_timestamp = float(move["time"])
		
		
		client_processed_buffer.push_back(move)

#server reconcialiation

func reconciliate(idx: int , player_world_update : Dictionary):
	var time_stamp : float = float(player_world_update["time"])
	
	while(idx < client_processed_buffer.size()):
		client_processed_buffer[idx] = player_world_update
		position = lerp(position, Vector2(player_world_update["x"], player_world_update["y"]), LERP_RATE)
		#move_and_slide()
		idx+=1 
		



#syncing with server
func process_world_update(player_world_update : Dictionary):
	
	if (is_client):
		#print(player_world_update["time"])
		var new_authoritative_time : float = float(player_world_update["time"])
		
		if (last_authoritative_time == 0.0):
			last_authoritative_time = new_authoritative_time

		## On recule jusqu'au dernier temps d'autorité
		## On discarte tout ce qui est avant ce temps
		for i in range(client_processed_buffer.size() - 1, 0 , -1):
			#print(str(temp["time"]) + " " + str(last_authoritative_time))
			if(float(client_processed_buffer[i]["time"]) < last_authoritative_time):
				var temp = client_processed_buffer.pop_at(i)
				i-=1
				#client_processed_buffer.push_back(temp)
				
		
		#print(client_processed_buffer.size())
		
		## À chaque temps d'autorité qu'on a
		## On vérifie si les coordonnées pour ce temps sont les même
		var idx = 0
		for buffer in client_processed_buffer:
			if(float(buffer["time"])  > new_authoritative_time):
				break
			if (float(buffer["time"]) == new_authoritative_time):
				if (float(player_world_update["x"]) != float(buffer["x"]) || float(player_world_update["y"]) != float(buffer["y"])):
					reconciliate(idx, player_world_update)
					
			idx += 1
				
		
		

			

		last_authoritative_time = new_authoritative_time
			#position = lerp(position, Vector2(player_world_update["x"], player_world_update["y"]), LERP_RATE)
			#direction = Vector2(player_world_update["viewangle_side"], player_world_update["viewangle_up"])
	#position = Vector2(player_world_update["x"], player_world_update["y"])

func get_client_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * speed
	
	var normalizedVector = velocity.normalized()
	var buttons = []
	
	
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
		"time": last_processed_timestamp,
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
	
	last_processed_timestamp = float(oldest_input["time"])
	#get_tree().quit()
