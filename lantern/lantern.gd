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


func _ready() -> void:
	LanternManager.register(self)
	GameEvents.itemEffectApplied.connect(onItemEffect)
	cone.light_energy = energy
	cone.spot_attenuation = attenuation
	cone.spot_angle = angle 
	cone.spot_range = lightRange

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

func onItemEffect(effectType:String, effectValue:float):
	print("Effect received: ", effectType, " value: ", effectValue)
	if effectType == "LanternSpeed":
		rotationSpeed *= effectValue
	if effectType == "Energy":
		energy *= effectValue
		cone.light_energy = energy
		omni_light_3d.light_energy += 0.05
	if effectType == "Angle":
		angle *= effectValue
		cone.spot_angle = angle
		omni_light_3d.omni_range += 0.8
	if effectType == "Range":
		lightRange *= effectValue
		cone.spot_range = lightRange
		omni_light_3d.omni_range += 1.2
