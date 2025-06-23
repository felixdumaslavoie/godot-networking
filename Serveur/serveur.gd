# server_node.gd
class_name ServerNode
extends Node

var server = UDPServer.new()
var peers = []

const TIME_STEP : float = 0.035 # In sec
var time : float = Time.get_unix_time_from_system() 
var deltaTime : float = 0

var latestId : int = 0

func createID() -> int :
	latestId += 1
	return latestId
	


func addNewClient(peer : PacketPeerUDP) -> Dictionary :
	
	var newPlayer = load("res://Shared/player.tscn").instantiate()
	add_child(newPlayer)
	
	var initPeer = {
		"id" : createID(),
		"socket": peer,
		"inputs": [],
		"Player": newPlayer
	}
	return initPeer

func _ready():
	server.listen(4242)

func _process(delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var packet : PackedByteArray = peer.get_packet()
	
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_local_port()])
		print("Received data: %s" % [packet.get_string_from_utf8()])
		# Reply so it knows we received the message.
		peer.put_packet(packet)
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(addNewClient(peer))
		
	# Do something with the connected peers.
	for i in range(0, peers.size()):
		# Update authoritative data 
		var slicedInput = peers[i]["inputs"].pop_front() 
		if (slicedInput != null):
			peers[i]["Player"].process_inputs(slicedInput)
			
		var packet = peers[i]["socket"].get_packet()
		if (packet):
			var json_string : Dictionary = {}
			
			if (JSON.parse_string(packet.get_string_from_utf8()) != null ):
				json_string = JSON.parse_string(packet.get_string_from_utf8())
			
				if (json_string != null):
					var data : Dictionary = json_string
					if data:
						if typeof(data) == TYPE_DICTIONARY:
							
							var receivedData = {
								"time": data["time"],
								"sidemove": data["sidemove"],
								"upmove": data["upmove"],
								"buttons": data["buttons"]
							}
							peers[i]["inputs"].push_back(receivedData)
							#print(peers[i]["inputs"])
						else:
							print("Error parsing data from client")
							
					else:
						print("JSON Parse Error: ", data, " in ", json_string)
			
	#if time > timeStep, send authoritative data 
	deltaTime = Time.get_unix_time_from_system() - time
	
	if (deltaTime >= TIME_STEP):
		send_authoritative_data()
		deltaTime = 0
		time = Time.get_unix_time_from_system()
	
	
func update_authoritative_data(player, inputs):
	player["process_inputs"].call(inputs)
	
	
func send_authoritative_data():
	for i in range(0, peers.size()):
		for j in range(0, peers.size()):
			var packet = JSON.stringify(peers[j]["Player"].get_state()).to_utf8_buffer()
			peers[i]["socket"].put_packet(packet)
	 
func get_peers() -> Array : 
	return peers 
