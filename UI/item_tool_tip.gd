class_name ItemToolTip

extends PanelContainer
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_description_label: Label = %ItemDescriptionLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false 

func showToolTip (item: ItemData, slot_position : Vector2):
	item_name_label.text = item.itemName
	item_description_label.text = item.description
	
	global_position = slot_position + Vector2(20,50)
	visible = true 

func hideToolTip():
	visible = false 
