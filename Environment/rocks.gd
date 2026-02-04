@tool
extends GridMap

@export_tool_button("Randomize Rotations") var randomize_btn = _on_randomize_pressed

func _on_randomize_pressed():
	randomize_rotations()

func randomize_rotations():
	var cells = get_used_cells()
	print("Found ", cells.size(), " cells")
	for cell in cells:
		var item = get_cell_item(cell)
		var random_orientation = randi() % 24
		set_cell_item(cell, item, random_orientation)
