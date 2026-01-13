extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var name_entry: LineEdit = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/name_entry

const PORT := 9999
var enet_peer := ENetMultiplayerPeer.new()

var local_player_name: String

func _on_host_button_pressed():
	local_player_name = name_entry.text.strip_edges()
	if local_player_name == "":
		local_player_name = "Player"

	var err = enet_peer.create_server(PORT)
	if err != OK:
		print("❌ Failed to start server:", err)
		return

	multiplayer.multiplayer_peer = enet_peer
	print("✅ Server started on port", PORT)

	# Change scene AFTER server is ready
	get_tree().change_scene_to_file("res://bingo_main.tscn")

func _on_join_button_pressed():
	local_player_name = name_entry.text.strip_edges()
	if local_player_name == "":
		local_player_name = "Player"

	var ip = address_entry.text
	if ip == "":
		ip = "127.0.0.1"

	var err = enet_peer.create_client(ip, PORT)
	if err != OK:
		print("❌ Failed to connect to server:", err)
		return

	multiplayer.multiplayer_peer = enet_peer
	print("✅ Connecting to", ip)

	get_tree().change_scene_to_file("res://bingo_main.tscn")
