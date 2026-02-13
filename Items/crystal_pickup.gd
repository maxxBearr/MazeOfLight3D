extends Area3D

@export var item : ItemData
@export var setCrystalLight : Color
var playerInrange :Player = null
@onready var crystal_mesh_1: MeshInstance3D = %CrystalMesh1
@onready var crystal_light: OmniLight3D = %CrystalLight
@onready var crystal_select: Node3D = %CrystalSelect
@export var crystalTypes : ItemData.CrystalTypes

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	body_exited.connect(onBodyExited)
	crystal_select.visible = false

	if crystalTypes == ItemData.CrystalTypes.General:
		setCrystalLight = Color.WHITE
	elif crystalTypes == ItemData.CrystalTypes.Red:
		setCrystalLight = Color.RED
	elif crystalTypes == ItemData.CrystalTypes.Blue:
		setCrystalLight = Color.BLUE
	elif crystalTypes == ItemData.CrystalTypes.Green:
		setCrystalLight = Color.GREEN
	
	crystal_light.light_color = setCrystalLight
	var mat = crystal_mesh_1.get_surface_override_material(0).duplicate()
	crystal_mesh_1.set_surface_override_material(0, mat)
	mat.set_shader_parameter("albedo", setCrystalLight)
	
	
	
	
	var selectLight = crystal_select.get_node("CrystalSelectLight")
	var selectLight2 = crystal_select.get_node("CrystalSelectLight2")
	var selectLight3 = crystal_select.get_node("CrystalSelectLight3")

	if selectLight:
		var color = setCrystalLight
		var newColorH = wrapf(color.h + randf_range(color.h -0.15, color.h +0.15), 0.0,1.0)
		selectLight.light_color = Color.from_hsv(newColorH,1.0, 1.0)
	if selectLight2:
		var color = setCrystalLight
		var newColorH = wrapf(color.h + randf_range(color.h -0.15, color.h +0.15), 0.0,1.0)
		selectLight2.light_color = Color.from_hsv(newColorH,1, 1)
	if selectLight3:
		var color = setCrystalLight
		var newColorH = wrapf(color.h + randf_range(color.h -0.15, color.h +0.15), 0.0,1.0)
		selectLight3.light_color = Color.from_hsv(newColorH,1, 1)
func _process(delta: float) -> void:
	if playerInrange and Input.is_action_just_pressed("Interact") and InventoryManager.isFull() == false:
		openSelection(crystalTypes)
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

func openSelection(crystal: ItemData.CrystalTypes):
	var mainCamera = get_viewport().get_camera_3d()
	crystal_select.global_position = mainCamera.global_position + (-mainCamera.global_transform.basis.z *15) + (-mainCamera.global_transform.basis.y *5)
	crystal_select.rotation.y = mainCamera.rotation.y
	crystal_select.updateCrystalType(crystal)
	crystal_select.visible = true
	get_tree().paused = true
