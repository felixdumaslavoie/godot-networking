extends Node

var instances = {}

var t = 0.0

var camSpeed = 20

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
	
func get_input():
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, $Camera2D.zoom.x + 0.25, t)
		$Camera2D.zoom.y  = lerp($Camera2D.zoom.y, $Camera2D.zoom.y + 0.25, t)
	if Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, $Camera2D.zoom.x - 0.25, t)
		$Camera2D.zoom.y  =  lerp($Camera2D.zoom.y, $Camera2D.zoom.y - 0.25, t)
	
	var input_direction = Input.get_vector("left", "right", "up", "down")
	$Camera2D.position += input_direction * camSpeed
	

func _process(delta: float) -> void:
	
	ImGui.Begin("FPS")
	ImGui.Text(str(Engine.get_frames_per_second()).pad_decimals(2))
	ImGui.End()
	ImGui.Begin("Peers")
	for peer in instances["serveur"].get_peers():
		
		ImGui.SetNextItemOpen(true)
		if ImGui.CollapsingHeader( "Client " + str(peer["id"]) ):
			ImGui.LabelText(  str(peer["socket"].get_packet_ip()) + ":"+ str(peer["socket"].get_local_port()), "socket: ")
			ImGui.LabelText(  "Lorem ipsum", "Position (x,y) " + ":" )
	ImGui.End()
	
	get_input()
	
func _physics_process(delta: float) -> void:
	t += delta * 0.01
