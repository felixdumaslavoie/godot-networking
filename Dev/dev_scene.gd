extends Node

var instances = {}

# Constructor
func _init():
	Engine.max_fps = 60
	var client : ClientNode =  load("res://Client/client.tscn").instantiate()
	var serveur : ServerNode = load("res://Serveur/serveur.tscn").instantiate()
	
	add_child(client)
	add_child(serveur)
	
	instances = {
		"serveur" : serveur, 
		"client" : client
	}

func _process(delta: float) -> void:
	
	ImGui.Begin("FPS")
	ImGui.Text(str(Engine.get_frames_per_second()).pad_decimals(2) + "                      ")
	ImGui.End()
	ImGui.Begin("Peers")
	for peer in instances["serveur"].get_peers():
		
		ImGui.SetNextItemOpen(true)
		if ImGui.CollapsingHeader( "Client " + str(peer["id"]) ):
			ImGui.LabelText(  str(peer["socket"].get_packet_ip()) + ":"+ str(peer["socket"].get_local_port()), "socket: ")
			ImGui.LabelText(  "Lorem ipsum", "Position (x,y) " + ":" )
			
		
	ImGui.End()
