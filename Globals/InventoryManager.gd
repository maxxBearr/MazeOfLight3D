extends Node

signal itemAdded(item: ItemData, slotIndex : int)
signal itemRemoved(item: ItemData, slotIndex: int)
signal unableToAdd
signal demoFinished(message: String)
signal inventoryChanged

var maxSlots : int = 10
var slots : Array = []


func _ready() -> void:
	slots.resize(maxSlots)
	slots.fill(null)

func addItem(item:ItemData) -> bool:
	if slots.find(null) == -1:
		unableToAdd.emit()
		checkDemoFinished()
		return false
	else:
		var firstAvailableSlot = slots.find(null)
		slots[firstAvailableSlot] = item
		itemAdded.emit(item, firstAvailableSlot)
		inventoryChanged.emit()
		checkDemoFinished()
		return true
func removeItem(slotIndex:int) -> ItemData:
	if slotIndex <0 or  slotIndex >= maxSlots:
		return null
	var item = slots[slotIndex]
	if item != null:
		itemRemoved.emit(item, slotIndex)
		inventoryChanged.emit()
		slots[slotIndex] = null
	return item

func isFull() -> bool:
	if slots.find(null) == -1:
		return true
	else:
		return false

func getFilledSlotsCount() -> int:
	var filledSlots : int = 0
	for item in slots:
		if item != null:
			filledSlots +=1
	return filledSlots

func checkDemoFinished():
	if getFilledSlotsCount() > 5:
		demoFinished.emit("You found all crystals!
		Thank you for playing the demo!")
		get_tree().create_timer(4.0).timeout.connect(func(): 
			get_tree().paused = true
			get_tree().quit())

func getActiveCrystals() -> Array[ItemData]:
	var activeCrystals: Array[ItemData] = []
	for crystal in slots:
		if crystal != null and crystal.hasCharge():
			activeCrystals.append(crystal)
	return activeCrystals
		
func getCountOfItem(item: ItemData) -> int:
	var matchingSlots : int = 0
	for x in slots:
		if x == item:
			matchingSlots +=1
	return matchingSlots
