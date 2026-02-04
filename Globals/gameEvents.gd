extends Node


#Pick Up Item
signal itemEffectApplied(effectType:String, effectValue:float)

signal itemPickedUp(item:ItemData)


#Show interact prompt 
signal showInteractPrompt (itemName:String)
signal hideInteractPrompt



signal playerDied
signal demoFinished


func _ready() -> void:
	playerDied.connect(onPlayerDied)


func onPlayerDied():
	demoFinished.emit("You died
	Hint: the enemies take damage from light and color")
	get_tree().paused = true
	get_tree().create_timer(5.0).timeout.connect(func(): 
		get_tree().paused = false
		get_tree().reload_current_scene())
