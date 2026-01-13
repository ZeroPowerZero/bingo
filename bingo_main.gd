extends Control

@onready var grid = $GridContainer
@onready var bingo_label = $Label

enum { FILL_MODE, CUT_MODE }
var game_mode = FILL_MODE

var bingo_check : Array[bool] =[false]


var current_number := 1
var filled :Array[int] = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bingo_check.resize(25)
	bingo_check.fill(false)
	
	filled.resize(25)
	filled.fill(0)

	for i in range(25):
		var btn = grid.get_child(i)
		btn.text = ""
		btn.pressed.connect(on_cell_pressed.bind(i))
	


func on_cell_pressed(index):
	if game_mode == FILL_MODE:
		if current_number > 25:	
			game_mode = CUT_MODE
			return   # filling done
		
		if filled[index] != 0:
			return   # already filled

		filled[index] = current_number
		grid.get_child(index).text = str(current_number)

		current_number += 1
		return
		
# ---------------- CUT MODE ------------------

	print("not its cross time")
	if bingo_check[index]:
		return  # already cut

	bingo_check[index] = true
	grid.get_child(index).text = "❌"

	check_bingo()

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
func _process(delta: float) -> void:
	pass
