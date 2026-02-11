class_name ItemSlot
extends TextureRect
var itemData : ItemData = null 
@export var emptySlotText : Texture2D
@onready var item_tool_tip: ItemToolTip = %ItemToolTip


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = emptySlotText
	mouse_entered.connect(onMouseEntered)
	mouse_exited.connect(onMouseExited)


func isEmpty () -> bool:
	return itemData == null
	
func addItem (item : ItemData):
	itemData = item 
	if item.icon:
		texture = item.icon


func onMouseEntered ():
	if itemData:
		item_tool_tip.showToolTip(itemData, global_position)

func onMouseExited():
	item_tool_tip.hideToolTip()
