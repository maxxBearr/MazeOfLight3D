class_name ItemToolTip

extends PanelContainer
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_description_label: Label = %ItemDescriptionLabel
@onready var charge_label: Label = %ChargeLabel
@onready var activity_label: Label = %ActivityLabel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false 

func showToolTip (item: ItemData, slot_position : Vector2):
	item_name_label.text = item.itemName
	item_description_label.text = item.description
	activity_label.text = "Effect Strength: " + str(CrystalManager.getEffectStrength(item.effectType) - 1.0)
	charge_label.text = str(snapped(item.getCurrentCharge(), 0.01))
	global_position = slot_position + Vector2(20,50)
	visible = true 

func hideToolTip():
	visible = false 
