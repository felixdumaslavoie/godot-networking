# client_node.gd
class_name ClientNode
extends Node

var udp : PacketPeerUDP = PacketPeerUDP.new()
var connected : bool = false

@export var HOST : String = "127.0.0.1"
@export var PORT : int = 4242

const TICK_RATE : int = 60
var tick = 0

var world_objects = {}
var player_reference: Player = null
var map = []

var id : int = 0 # client id

func _init() -> void:
	var player = load("res://Shared/player.tscn").instantiate()
	player.name = "ClientPlayer"
	player_reference = player
	
	add_child(player)

func _ready():
	udp.connect_to_host(HOST, PORT)
	
func set_client():
	$ClientPlayer.is_client = true

func _process(delta):
	tick += 1
	
	if !connected:
		# Try to contact server
		var contactPayload = {}
		var connectionJSON = JSON.stringify(contactPayload) 
		udp.put_packet(connectionJSON.to_utf8_buffer())
		
	if udp.get_available_packet_count() > 0:
		var json_data : Dictionary = JSON.parse_string( udp.get_packet().get_string_from_utf8())
		if (json_data.has("id")):
			id = json_data["id"]
			player_reference.id = id
			add_world_object(str(id), player_reference)
			connected = true
		elif (json_data.has(str(id))):
			if (json_data != null):
				set_world_objects(json_data)
				receiving_world_update(json_data)
			
		
		
	
	
		
func set_world_objects(world_update : Dictionary):
	var peers : Array = world_update["data"]["peers"]

	for i in range(0, peers.size()):
		var extracted_id : int = int(peers[i])
		var node_exists = false
		for node in self.get_children():
			if (node.name == str(extracted_id)):
				node_exists = true
			elif (!world_objects.has(str(extracted_id))):
				var non_client_player : Player =  load("res://Shared/player.tscn").instantiate()
				non_client_player.name = str(extracted_id)
				add_world_object(str(extracted_id), non_client_player)
	
						
func add_world_object(id : String, object):
	add_child(object)
	world_objects[id] = object

func receiving_world_update(world_update : Dictionary):
	var peers : Array = world_update["data"]["peers"]
	var time_stamp = world_update["data"]["time"]
	
	for i in range(0, peers.size()):
		var extracted_id : String = str(int(peers[i]))
		
		if (world_update.has(extracted_id)):
			
			var data : Dictionary = world_update[extracted_id]
			#print(data)
			if (data.has("x") && data.has("y") && data.has("viewangle_side") && data.has("viewangle_up")): # data verification
				
				var player_authoritative_data : Dictionary = {
					"id": extracted_id,
					"time": time_stamp,
					"x" :  data["x"],
					"y" :  data["y"],
					"viewangle_side": data["viewangle_side"],
					"viewangle_up": data["viewangle_up"],
					"speed": "speed",
				}
				
				if (world_objects.has(extracted_id)):
					world_objects[extracted_id].process_world_update(player_authoritative_data)


func send_input_to_server(inputs : Dictionary):
	if connected: 
		var serialized_inputs = JSON.stringify(inputs)
		udp.put_packet(serialized_inputs.to_utf8_buffer())
		
		
func getClientPlayerLocation() -> Vector2 :
		return $ClientPlayer.get_location()
		
func set_id(id : int):
	self.id = id
	$ClientPlayer.id = id

func get_id() -> int: 
	return self.id
