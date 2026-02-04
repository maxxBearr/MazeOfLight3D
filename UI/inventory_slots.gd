extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UImanager.registerInventoryUI(self)

func updateSlot(item:ItemData, slotIndex:int):
	var slot = get_child(slotIndex)
	var itemSlot := slot as ItemSlot
	itemSlot.addItem(item)
