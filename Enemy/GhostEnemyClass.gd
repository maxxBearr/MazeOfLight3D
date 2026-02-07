class_name GhostEnemy 
extends Area3D

@export var health : float = 100
@export var speed : float = 2.0
@export var inherentColor : Color
@export var damage: int = 1
## energy tends to be around values of 3.5-5
@export_range(1.0, 40, 0.01) var energyResistance : float = 5
## range tends to hold 6-15
@export_range(1.0, 50.0, 0.025) var rangeResistance : float = 8
## angle tends to be around 18-25
@export_range(1.0, 60.0, 0.025) var angleResistance: float = 11
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@export var damageLabelScene : PackedScene 
var labelCooldown :float = 0.0
@onready var death_sound: AudioStreamPlayer3D = %DeathSound
@onready var deal_damage_sound: AudioStreamPlayer3D = %DealDamageSound

var startingHealth
@onready var basic_sound: AudioStreamPlayer3D = %BasicSound

func _ready() -> void:
	body_entered.connect(onBodyEntered)
	startingHealth = health
	var ownLight : OmniLight3D = self.get_node("OmniLight3D")
	ownLight.light_color = inherentColor
	syncShaderToInherentColor()
	basic_sound.play()

func _physics_process(delta: float) -> void:
	var playerPOS = EnemyManager.getPlayerPosition()
	var direction = global_position.direction_to(playerPOS)
	global_position += direction * speed * delta
	look_at(playerPOS)
	if LanternManager.isInCone(global_position) == true:
		takeDamage(delta)
		print(health)
	if health <= 0:
		set_physics_process(false)
		var tween = create_tween()
		tween.tween_property(get_node("GhostMesh"), "transparency", 1.0,1.0)
		basic_sound.stop()
		death_sound.play()
		death_sound.finished.connect(death)
	

func onBodyEntered(body):
	print("hit:", body)
	if body is Player:
		var tween = create_tween()
		tween.tween_property(get_node("GhostMesh"), "transparency", 1.0,1.0)
		body.takeDamage(damage) 
		deal_damage_sound.play()
		deal_damage_sound.finished.connect(death)
	


func death ():
	queue_free()

func syncShaderToInherentColor():
	var mat = $GhostMesh.get_surface_override_material(0).duplicate()
	$GhostMesh.set_surface_override_material(0, mat)
	mat.set_shader_parameter("albedo", inherentColor)




func takeDamage(delta: float):
	var lightHue = LanternManager.getCurrentColor().h 
	var eDamage = LanternManager.currentLantern.energy / energyResistance
	var rDamage = LanternManager.currentLantern.lightRange / rangeResistance
	var aDamage = LanternManager.currentLantern.angle / angleResistance
	var directDist = abs(lightHue - inherentColor.h)
	var wrapDist = 1.0 - directDist
	var shorestDist = min(directDist, wrapDist)
	var tolerance = 0.1
	var cDamage 
	var damageMult = LanternManager.currentLantern.damageMutliplier
	var totalDamage : float
	var damageColor : Color
	if shorestDist >= tolerance:
		if shorestDist < 0.62 and shorestDist > 0.38:
			cDamage = startingHealth * 0.2
			damageColor = Color.GREEN
		else:
			cDamage = startingHealth * 0.08
			damageColor = Color.YELLOW
		health -= ((eDamage + rDamage + aDamage + cDamage) * damageMult) * delta
		totalDamage = ((eDamage + rDamage + aDamage + cDamage) * damageMult) * delta
	else:
		cDamage = 0.0
		health -= ((eDamage + rDamage + aDamage + cDamage) * 0.4 * damageMult) * delta
		totalDamage = ((eDamage + rDamage + aDamage + cDamage) * 0.4 * damageMult) * delta
		damageColor = Color.RED
	
	labelCooldown -= delta
	if labelCooldown <= 0.0:
		spawnDamageLabel(totalDamage, damageColor)
		labelCooldown = 0.23
	print(cDamage)


func spawnDamageLabel(amount : int, color : Color):
	var label = damageLabelScene.instantiate()
	get_tree().root.add_child(label)
	label.global_position = global_position + Vector3(0,1,0)
	label.text = "-" + str(snapped(amount, 0.01))
	label.modulate = color
