extends Node3D
@onready var camera_3d: Camera3D 
@onready var selectable1_base_pos = $Selectable1.position
@onready var selectable2_base_pos = $Selectable2.position
@onready var selectable3_base_pos = $Selectable3.position
@onready var selectable_1: MeshInstance3D = %Selectable1
@onready var selectable_2: MeshInstance3D = %Selectable2
@onready var selectable_3: MeshInstance3D = %Selectable3

var selectable1_popped: bool = false
var selectable2_popped: bool = false
var selectable3_popped: bool = false

var tween1 : Tween
var tween2: Tween
var tween3: Tween

var selectableGroup := []

@onready var crystal_select_light: SpotLight3D = %CrystalSelectLight
@onready var crystal_select_light_2: SpotLight3D = %CrystalSelectLight2
@onready var crystal_select_light_3: SpotLight3D = %CrystalSelectLight3


@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var item_2: Label = %Item2
@onready var item_3: Label = %Item3
@onready var item_1: Label = %Item1

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var isSelecting = false



@export var possibleItems : Array[ItemData]
var selectedItems: Array[ItemData] = []

@onready var crystal_16: MeshInstance3D = $crystal_16/crystal_16
@onready var crystal_17: MeshInstance3D = $crystal_17/crystal_16
@onready var crystal_18: MeshInstance3D = $crystal_18/crystal_18
@onready var crystal_19: MeshInstance3D = $crystal_20/crystal_18
@onready var crystal_20: MeshInstance3D = $crystal_7/crystal_18
@onready var crystal_21: MeshInstance3D = $crystal_19/crystal_18
@onready var crystal_5: MeshInstance3D = $crystal_6/crystal_5


var arrayOfBase = []
var currentType : ItemData.CrystalTypes
var filteredItems = []

func _ready() -> void:
	camera_3d = get_viewport().get_camera_3d()
	selectableGroup = [selectable_1, selectable_2, selectable_3]
	arrayOfBase = [crystal_5,crystal_16,crystal_17,crystal_18,crystal_19,crystal_20,crystal_21]


func selectRandomItems():
	var available = filteredItems.duplicate()
	available.shuffle()
	selectedItems = [
		available[0],
		available[1],
		available[2]
	]

func updateCrystalType(crystalType : ItemData.CrystalTypes):
	var newColor : Color
	if crystalType == ItemData.CrystalTypes.General:
		newColor = Color.WHITE
	elif crystalType == ItemData.CrystalTypes.Red:
		newColor = Color.RED
	elif crystalType == ItemData.CrystalTypes.Blue:
		newColor = Color.BLUE
	elif crystalType == ItemData.CrystalTypes.Green:
		newColor = Color.GREEN
	
	for option:MeshInstance3D in selectableGroup:
		var mat = option.get_surface_override_material(0).duplicate()
		option.set_surface_override_material(0, mat)
		mat.set_shader_parameter("albedo", newColor)
	for option:MeshInstance3D in arrayOfBase:
		var baseColor = newColor
		var h = wrapf(baseColor.h + randf_range(-0.1, 0.1), 0.0, 1.0)
		var s = baseColor.s
		var v = baseColor.v

		baseColor = Color.from_hsv(h, s, v)

		var mat = option.get_surface_override_material(0).duplicate()
		option.set_surface_override_material(0, mat)
		mat.set_shader_parameter("albedo", baseColor)
		
	filteredItems = possibleItems.filter(func(checkMe:ItemData) ->bool:
		if checkMe.crystalType == crystalType:
			return true
		return false)
	selectRandomItems()
	updateLabels()


func updateLabels():
	item_1.text = selectedItems[0].itemName
	item_2.text = selectedItems[1].itemName
	item_3.text = selectedItems[2].itemName
func _process(delta: float) -> void:
	if not visible:
		pass
	if not camera_3d:
		camera_3d = get_viewport().get_camera_3d()
	#print("Camera current: ", camera_3d.current)
	#print("Selectable1 global pos: ", selectable_1.global_position)
	#print("Label1 result pos: ", camera_3d.unproject_position(selectable_1.global_position + Vector3(3,14.0,0.0)))
	item_1.position = camera_3d.unproject_position(selectable_1.global_position + Vector3(3,14.0,0.0))
	item_2.position = camera_3d.unproject_position(selectable_2.global_position + Vector3(-7.0,6.5,0.0))
	item_3.position = camera_3d.unproject_position(selectable_3.global_position + Vector3(-0.5,10.0,0.0))
	if visible:
		canvas_layer.visible = true


func _input(event) -> void:
	if not visible:
		return
	if isSelecting:
		return
	if event is InputEventMouseMotion:
		var mousePos := get_viewport().get_mouse_position()
		var camera = camera_3d
	
		var rayOrigin = camera.project_ray_origin(mousePos)
		var rayDirection = camera.project_ray_normal(mousePos)
		var reayEnd = rayOrigin + rayDirection * 500
		#print("Origin: ", rayOrigin, " Direction: ", rayDirection)
	
		var spaceState = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(rayOrigin, reayEnd)
		query.collide_with_areas = true
		var result = spaceState.intersect_ray(query)
		
		var hit_crystal : Node3D = null
		if result:
			hit_crystal = result.collider.get_parent()
			#print(result.collider.get_parent())

		var should_pop_1 = (hit_crystal == selectable_1)
		if should_pop_1 != selectable1_popped:
			selectable1_popped = should_pop_1
			tweenSelect1(should_pop_1)

		var should_pop_2 = (hit_crystal == selectable_2)
		if should_pop_2 != selectable2_popped:
			selectable2_popped = should_pop_2
			tweenSelect2(should_pop_2)

		var should_pop_3 = (hit_crystal == selectable_3)
		if should_pop_3 != selectable3_popped:
			selectable3_popped = should_pop_3
			tweenSelect3(should_pop_3)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selectable1_popped:
				selectCrystal(selectable_1, 0)
			elif selectable2_popped:
				selectCrystal(selectable_2, 1)
			elif selectable3_popped:
				selectCrystal(selectable_3,2)


func selectCrystal (crystal: Node3D, index : int):
	isSelecting = true
	var item = selectedItems[index]
	match crystal:
		selectable_1:
			animation_player.play("PopOut1")
		selectable_2:
			animation_player.play("PopOut2")
		selectable_3:
			animation_player.play("PopOut3")
	await animation_player.animation_finished
	InventoryManager.addItem(item)
	if item.effectType == ItemData.EffectTypes.RechargeAllCrsyatls:
		for items in range(InventoryManager.slots.size()):
			if item != null:
				var cry = InventoryManager.slots[items]
				cry.currentCharge += cry.maxCharge * 0.2
	print("selected:", item.itemName)
	get_tree().paused = false
	get_parent().queue_free()

func tweenSelect1(popped: bool):
	if tween1 and tween1.is_running():
		tween1.kill()
	tween1 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if popped:
		tween1.tween_property(selectable_1, "position", selectable1_base_pos + Vector3(0,2.0,2.0), 0.3)
	else:
		tween1.tween_property(selectable_1,"position", selectable1_base_pos, 0.2)
func tweenSelect2(popped: bool):
	if tween2 and tween2.is_running():
		tween2.kill()
	tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if popped:
		tween2.tween_property(selectable_2, "position", selectable2_base_pos + Vector3(-1.0,1.0,0.0), 0.3)
	else:
		tween2.tween_property(selectable_2,"position", selectable2_base_pos, 0.2)
func tweenSelect3(popped: bool):
	if tween3 and tween3.is_running():
		tween3.kill()
	tween3 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if popped:
		tween3.tween_property(selectable_3, "position", selectable3_base_pos + Vector3(0.0,0.6,-1.3), 0.3)
	else:
		tween3.tween_property(selectable_3,"position", selectable3_base_pos, 0.2)
