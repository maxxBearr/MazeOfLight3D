class_name ItemData
extends Resource

@export var itemName : String
@export var description : String
@export var icon : Texture2D
@export var effectType: String 
@export var effectValue : float 
@export var maxCharge : float = 31
@export var currentCharge : float = 31


func getCurrentCharge()-> float:
	return currentCharge / maxCharge

func hasCharge() -> bool:
	if currentCharge < 0.01:
		return false
	return true
