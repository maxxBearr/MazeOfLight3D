class_name ItemSlot
extends TextureRect
var itemData : ItemData = null 
@export var emptySlotText : Texture2D
@onready var item_tool_tip: ItemToolTip = %ItemToolTip
var mySlotIndex : int = -1
var basePos
var baseScale
var tween : Tween
var CRYSTALICON_SLOT_PNG = preload("uid://b348urhaxejbt")
var currentColor : Color = Color.ANTIQUE_WHITE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = emptySlotText
	mouse_entered.connect(onMouseEntered)
	mouse_exited.connect(onMouseExited)
	CrystalManager.crystalChargeChanged.connect(onCrystalChargeChanged)
	CrystalManager.activeZoneChanged.connect(onActiveZoneChanged)
	baseScale = scale
	tooltip_text = "see how i look"


func isEmpty () -> bool:
	return itemData == null
	
func addItem (item : ItemData):
	basePos = position
	itemData = item 
	if item.icon:
		texture = item.icon
		if item.crystalType == item.CrystalTypes.Red:
			modulate = Color.RED
			currentColor = Color.RED
		if item.crystalType == item.CrystalTypes.Blue:
			modulate = Color.BLUE
			currentColor = Color.BLUE
		if item.crystalType == item.CrystalTypes.Green:
			modulate = Color.GREEN
			currentColor = Color.GREEN
		if item.crystalType == item.CrystalTypes.General:
			modulate = Color.NAVAJO_WHITE
			currentColor = Color.NAVAJO_WHITE
		



func onMouseEntered ():
	if itemData:
		item_tool_tip.showToolTip(itemData, global_position)

func onMouseExited():
	item_tool_tip.hideToolTip()


func onCrystalChargeChanged (slotIndex : int):
	if mySlotIndex == slotIndex:
		if itemData != null:
			var chargePercent = itemData.getCurrentCharge()
			modulate = currentColor.lerp(Color.DARK_GRAY, 1.0 - chargePercent)
	
func onActiveZoneChanged (crystalDict : Dictionary):
	
	if itemData != null:
		if tween and tween.is_running():
			tween.kill()
		var activeStrength = crystalDict[itemData.crystalType]
		var newPos : Vector2 = basePos
		var newScale = baseScale
		if activeStrength == 1.0 and itemData.crystalType != itemData.CrystalTypes.General:
			tween = create_tween().set_parallel()
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(self, "position", Vector2(basePos.x, newPos.y -2.0), 0.8)
			tween.tween_property(self, "scale", newScale * 1.5, 0.8)
		elif activeStrength == 0.5:
			tween = create_tween().set_parallel()
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(self, "position",  Vector2(basePos.x, newPos.y - 1.0), 0.6)
			tween.tween_property(self, "scale", newScale * 1.25, 0.6)
		elif activeStrength < 0.5:

			tween = create_tween().set_parallel()
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(self, "position", basePos, 0.8)
			tween.tween_property(self, "scale", baseScale, 0.8)

func setSlotIndex(index :int):
	mySlotIndex = index
