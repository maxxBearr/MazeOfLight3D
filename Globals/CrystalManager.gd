extends Node
signal crystalDepleted
signal crystalChargeChanged(slotIndex : int)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().paused:
		return
	var anyDepleted = false
	for item in range(InventoryManager.slots.size()):
		var crystal = InventoryManager.slots[item]
		if crystal != null and crystal.hasCharge():
			crystal.currentCharge -= delta
			crystal.currentCharge = max(0.0, crystal.currentCharge)
			crystalChargeChanged.emit(item)
			if crystal.currentCharge <= 0.01:
				anyDepleted = true
	if anyDepleted == true:
		crystalDepleted.emit()
