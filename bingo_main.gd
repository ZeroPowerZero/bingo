extends Control

@onready var grid = $GridContainer
@onready var bingo_label = $Label

enum { FILL_MODE, CUT_MODE }
var game_mode = FILL_MODE

var bingo_check : Array[bool] =[false]


var current_number := 1
var filled :Array[int] = []

var players: Array[int] = [1,2]
var current_turn := 0
var my_peer_id := 0
var opp_filled : bool = false
var selected_num : int 

var is_my_turn : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		my_peer_id = multiplayer.get_unique_id()
		print(my_peer_id)
	else:
		my_peer_id = 2;
		print(my_peer_id)
		
	bingo_check.resize(25)
	bingo_check.fill(false)
	
	filled.resize(25)
	filled.fill(0)

	for i in range(25):
		var btn = grid.get_child(i)
		btn.text = ""
		btn.pressed.connect(on_cell_pressed.bind(i))


@rpc("any_peer")
func opp_has_filled():
	opp_filled = true
	
@rpc("any_peer","call_local")
func ur_turn():
	is_my_turn = true

func on_cell_pressed(index):
	if game_mode == FILL_MODE:
		if current_number > 25:
			if my_peer_id == 2:
				rpc("opp_has_filled")
				rpc_id(1,"ur_turn")
			game_mode = CUT_MODE
			return
		
		if filled[index] != 0:
			return

		filled[index] = current_number
		grid.get_child(index).text = str(current_number)
		current_number += 1
		return

	# ---------------- CUT MODE ------------------
	if !opp_filled:
		print("wait for opp to fill")
		
	if players.size() > 0 and !is_my_turn:
		print("Not your turn")
		return

	if bingo_check[index]:
		return
	
	bingo_check[index] = true
	
	selected_num = int(grid.get_child(index).text)
	grid.get_child(index).text = "❌"
	rpc("cross_ur_no",selected_num)
	rpc("ur_turn")
	is_my_turn = false
	check_bingo()

@rpc("any_peer","call_remote")
func cross_ur_no(num :int):
	grid.get_child(find(num)).text = "❌"

func find(num : int):
	for i in range(25):
		if filled[i]==num:
			return i
	
func check_bingo():
	var lines := 0

	# Rows
	for r in range(5):
		var complete := true
		for c in range(5):
			if !bingo_check[r * 5 + c]:
				complete = false
		if complete:
			lines += 1

	# Columns
	for c in range(5):
		var complete := true
		for r in range(5):
			if !bingo_check[r * 5 + c]:
				complete = false
		if complete:
			lines += 1

	# Diagonals
	if bingo_check[0] and bingo_check[6] and bingo_check[12] and bingo_check[18] and bingo_check[24]:
		lines += 1

	if bingo_check[4] and bingo_check[8] and bingo_check[12] and bingo_check[16] and bingo_check[20]:
		lines += 1

	update_bingo_label(lines)

func update_bingo_label(lines):
	var word = "BINGO"
	bingo_label.text = word.substr(0, min(lines, 5))

	if lines >= 5:
		print("🎉 BINGO!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
