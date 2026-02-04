extends Area3D

@export var item : ItemData
@export var setCrystalLight : Color = Color.BLUE_VIOLET
var playerInrange :Player = null
@onready var crystal_mesh_1: MeshInstance3D = %CrystalMesh1
@onready var crystal_light: OmniLight3D = %CrystalLight
@onready var crystal_select: Node3D = %CrystalSelect

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	body_exited.connect(onBodyExited)
	crystal_select.visible = false
	
	crystal_light.light_color = setCrystalLight
	
	var selectLight = crystal_select.get_node("CrystalSelectLight")
	var selectLight2 = crystal_select.get_node("CrystalSelectLight2")
	var selectLight3 = crystal_select.get_node("CrystalSelectLight3")

	if selectLight:
		selectLight.light_color = setCrystalLight
	if selectLight2:
		selectLight2.light_color.h = (setCrystalLight.h - 0.1)
	if selectLight3:
		selectLight3.light_color.h = setCrystalLight.h + 0.2
func _process(delta: float) -> void:
	if playerInrange and Input.is_action_just_pressed("Interact") and InventoryManager.isFull() == false:
		openSelection()
		GameEvents.hideInteractPrompt.emit()
	if crystal_select.visible == false:
		crystal_select.set_process(false)
		crystal_select.set_physics_process(false)
	elif crystal_select.visible == true:
		crystal_select.set_process(true)
		crystal_select.set_physics_process(true)


func onBodyEntered(body):
	if body is Player:
		playerInrange = body
		if InventoryManager.isFull() == false:
			GameEvents.showInteractPrompt.emit("Press E to pick up Crystal")
		elif InventoryManager.isFull() == true:
			GameEvents.showInteractPrompt.emit("Inventory Full")
		



func onBodyExited(body):
	if body is Player:
		playerInrange = null
		GameEvents.hideInteractPrompt.emit()

func openSelection():
	var mainCamera = get_viewport().get_camera_3d()
	
	crystal_select.global_position = mainCamera.global_position + (-mainCamera.global_transform.basis.z *15) + (-mainCamera.global_transform.basis.y *5)
	crystal_select.rotation.y = mainCamera.rotation.y
	crystal_select.visible = true
	get_tree().paused = true
