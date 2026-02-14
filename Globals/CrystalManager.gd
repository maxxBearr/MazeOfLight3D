extends Node
signal crystalDepleted
signal crystalChargeChanged(slotIndex : int)
signal activeZoneChanged(crystalDictionary: Dictionary)

var previousActivation= {}#this checks for color

func _process(delta: float) -> void:
	# this is crystal drain logic 

	if get_tree().paused:
		return
	var currentActiveColor :Dictionary=checkActiveCatagory(LanternManager.getCurrentColor().h)
	if currentActiveColor != previousActivation:
		activeZoneChanged.emit(currentActiveColor)
		previousActivation = currentActiveColor
	var anyDepleted = false
	for item in range(InventoryManager.slots.size()):
		var crystal = InventoryManager.slots[item]
		if crystal != null and crystal.hasCharge():
			var decayDelay = CrystalManager.getEffectStrength(ItemData.EffectTypes.SlowerDrain)
			var strength = currentActiveColor[crystal.crystalType]
			if strength == 1.0:
				crystal.currentCharge -= delta / decayDelay
			elif strength == 0.5:
				crystal.currentCharge -= (delta * 0.5) / decayDelay
			elif strength < 0.5:
				crystal.currentCharge -= (delta * 0.1) / decayDelay
			crystalChargeChanged.emit(item)
			crystal.currentCharge = max(0.0, crystal.currentCharge)
			if crystal.currentCharge <= 0.01:
				anyDepleted = true
	if anyDepleted == true:
		crystalDepleted.emit()
		
		


func checkActiveCatagory(lanternHue:float)-> Dictionary:
	var crystalDict : Dictionary = {
		ItemData.CrystalTypes.General : 1.0,
		ItemData.CrystalTypes.Red : 0.0,
		ItemData.CrystalTypes.Blue : 0.0,
		ItemData.CrystalTypes.Green : 0.0
	} 
	if (lanternHue > 0.86) or (lanternHue <= 0.089):
		#Red
		crystalDict[ItemData.CrystalTypes.Red] = 1.0
	elif lanternHue > 0.089 and lanternHue <= 0.19:
		#yellow
		crystalDict[ItemData.CrystalTypes.Red] = 0.5
		crystalDict[ItemData.CrystalTypes.Green] = 0.5
	elif lanternHue > 0.19 and lanternHue <= 0.47:
		#green
		crystalDict[ItemData.CrystalTypes.Green] = 1.0
	elif lanternHue > 0.47 and lanternHue <= 0.58:
		#cyan
		crystalDict[ItemData.CrystalTypes.Green] = 0.5
		crystalDict[ItemData.CrystalTypes.Blue] = 0.5
	elif lanternHue > 0.58 and lanternHue <= 0.73:
		#blue
		crystalDict[ItemData.CrystalTypes.Blue] = 1.0
	elif lanternHue > 0.73 and lanternHue <= 0.86:
		#magenbta
		crystalDict[ItemData.CrystalTypes.Blue] = 0.5
		crystalDict[ItemData.CrystalTypes.Red] = 0.5

	
	return crystalDict


func getEffectStrength(efctType:ItemData.EffectTypes)-> float:
	var finalMult = 1.0 
	for item in range(InventoryManager.slots.size()):
		var crystal:ItemData = InventoryManager.slots[item]
		if crystal != null and crystal.hasCharge():
			if crystal.effectType == efctType:
				var strength = previousActivation[crystal.crystalType]
				finalMult *= lerp(1.0, crystal.effectValue, strength )
	return finalMult



#yellow 0.09 -0.19
# green 0.2 - 0.47
#cyan 0.48 - 0.58
# blue 0.59 - 0.73
# magenta 0.74-0.86
#red 0.87 - 0.08
