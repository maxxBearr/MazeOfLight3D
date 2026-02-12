class_name ItemSlot
extends TextureRect
var itemData : ItemData = null 
@export var emptySlotText : Texture2D
@onready var item_tool_tip: ItemToolTip = %ItemToolTip
var mySlotIndex : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = emptySlotText
	mouse_entered.connect(onMouseEntered)
	mouse_exited.connect(onMouseExited)
	CrystalManager.crystalChargeChanged.connect(onCrystalChargeChanged)


func isEmpty () -> bool:
	return itemData == null
	
func addItem (item : ItemData):
	itemData = item 
	if item.icon:
		texture = item.icon
		modulate = Color.WHITE


func onMouseEntered ():
	if itemData:
		item_tool_tip.showToolTip(itemData, global_position)

func onMouseExited():
	item_tool_tip.hideToolTip()


func onCrystalChargeChanged (slotIndex : int):
	if mySlotIndex == slotIndex:
		if itemData != null:
			var chargePercent = itemData.getCurrentCharge()
			print("Slot ", mySlotIndex, " charge: ", chargePercent, " modulate will be: ", Color.WHITE.lerp(Color.DARK_GRAY, 1.0 - chargePercent))

			modulate = Color.WHITE.lerp(Color.DARK_GRAY, 1.0 - chargePercent)
	


func setSlotIndex(index :int):
	mySlotIndex = index
