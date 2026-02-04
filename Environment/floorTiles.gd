@tool
extends GridMap

@export_tool_button("Randomize Rotations") var randomize_btn = randomize_rotations

func randomize_rotations():
	var y_rotations = [0, 10, 16, 22]
	var cells = get_used_cells()
	for cell in cells:
		var item = get_cell_item(cell)
		var random_orientation = y_rotations.pick_random()
		set_cell_item(cell, item, random_orientation)
