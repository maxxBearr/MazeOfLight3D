extends Node
var inventorySlotsUI = null 
var healthBar: ProgressBar = null
var player : Player = null
var tellPlayerLabel : TellPlayer = null



func _ready() -> void:
	InventoryManager.itemAdded.connect(onItemAdded)
	InventoryManager.unableToAdd.connect(onUnableToAdd)
	InventoryManager.demoFinished.connect(onTextChanged)
	GameEvents.demoFinished.connect(onTextChanged)


func onItemAdded(item:ItemData,slotIndex:int):
	if inventorySlotsUI:
		inventorySlotsUI.updateSlot(item, slotIndex)

func onUnableToAdd():
	pass

func registerInventoryUI(UInode):
	inventorySlotsUI = UInode

func registerHealthBar(bar: ProgressBar):
	healthBar = bar
	initializeHealthBar()

func registerPlayer(playerNode: Player):
	player = playerNode
	player.healthChanged.connect(onHealthChanged)
	initializeHealthBar()

func registerTellPlayerLabel(label : TellPlayer):
	tellPlayerLabel = label
	tellPlayerLabel.textChanged.connect(onTextChanged)


func onHealthChanged(newHealth):
	healthBar.value = newHealth


func initializeHealthBar():
	if healthBar and player:
		healthBar.max_value = player.maxhealth
		healthBar.value = player.currentHealth


func onTextChanged(newText):
	tellPlayerLabel.printText(newText)
