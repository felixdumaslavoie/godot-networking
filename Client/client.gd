# client_node.gd
class_name ClientNode
extends Node

var udp = PacketPeerUDP.new()
var connected = false

const PORT = 4242
const HOST = "127.0.0.1"

func _ready():
	udp.connect_to_host(HOST, PORT)

func _process(delta):
	if !connected:
		# Try to contact server
		udp.put_packet("The answer is... 42!".to_utf8_buffer())
	if udp.get_available_packet_count() > 0:
		print("Connected: %s" % udp.get_packet().get_string_from_utf8())
		connected = true




var inputs : Array = []

func input_buffering(input : InputEventKey):

	var newInput = {
		"key" : input,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	input.push_back(newInput)
		
