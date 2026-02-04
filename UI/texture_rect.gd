extends TextureRect
var itemData : ItemData = null 
@export var emptySlotText : Texture2D
@onready var item_tool_tip: PanelContainer = %ItemToolTip


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = emptySlotText
	mouse_entered.connect(onMouseEntered)
	mouse_exited.connect(onMouseExited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func isEmpty () -> bool:
	return itemData == null
	
func addItem (item : ItemData):
	itemData = item 
	if item.icon:
		texture = item.icon
	applyEffect(item)

func applyEffect (item : ItemData):
	if item.effectType == "LanternSpeed":
		pass


func onMouseEntered ():
	if itemData:
		item_tool_tip.showToolTip(itemData, global_position)
		

func onMouseExited():
	item_tool_tip.hide()
