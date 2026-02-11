class_name Lantern
extends Node3D

@export var LightShape : PackedScene
@export var rotationSpeed := 0.025
@export var saturation := 0.5
@export var value := 0.75
@onready var cone: SpotLight3D = %cone
@onready var ray_cast_3d: RayCast3D = %RayCast3D
@export_group("LightSettings")
@export var energy :=4.0
@export var attenuation := 0.0
@export var angle := 20
@export var lightRange:= 10.0
@export var damageMutliplier : float = 10.0
var currentColor = Color.from_hsv(hue, saturation,value) 
var hue: float 
@onready var omni_light_3d: OmniLight3D = %OmniLight3D
var baseEnergy : float
var baseRotationSpeed : float
var baseAngle : float
var baseRange : float


func _ready() -> void:
	LanternManager.register(self)
	InventoryManager.inventoryChanged.connect(recalcEffects)
	CrystalManager.crystalDepleted.connect(recalcEffects)
	cone.light_energy = energy
	cone.spot_attenuation = attenuation
	cone.spot_angle = angle 
	cone.spot_range = lightRange
	baseAngle = angle
	baseEnergy = energy
	baseRange = lightRange
	baseRotationSpeed = rotationSpeed
func _process(delta: float) -> void:
	#cone.look_at(get_global_mouse_position())
	#cone.rotation += deg_to_rad(270)
	if Input.is_action_pressed("Rotate"):
		#print("shift is being pressed")
		#print(hue)
		#print("rotation speed =")
		#print(rotationSpeed)
		#print("energy =")
		#print(energy)
		hue = wrapf(hue + rotationSpeed * delta, 0.0, 1.0)
		currentColor = Color.from_hsv(hue,saturation,value)
		cone.light_color = currentColor
		#circle.color = cone.color
		omni_light_3d.light_color = currentColor
		
		
		
				
	



func recalcEffects():
	rotationSpeed = baseRotationSpeed
	lightRange = baseRange
	angle = baseAngle
	energy = baseEnergy
	var activeCrystals:Array[ItemData] = InventoryManager.getActiveCrystals()
	for crystal in activeCrystals:
		if crystal.effectType == "LanternSpeed":
			rotationSpeed *= crystal.effectValue
		if crystal.effectType == "Energy":
			energy *= crystal.effectValue
		if crystal.effectType == "Angle":
			angle *= crystal.effectValue
		if crystal.effectType == "Range":
			lightRange *= crystal.effectValue
	
	cone.light_energy = energy
	cone.spot_angle = angle
	cone.spot_range = lightRange
	omni_light_3d.omni_range = ((energy * 1.5 + angle * 1.1 + lightRange * 1.3) / 3)
	print("omni range == " + str(omni_light_3d.omni_range))
