class_name GhostEnemy 
extends Area3D

@export var health : float = 100
@export var speed : float = 2.0
@export var inherentColor : Color
@export var damage: float = 1.0
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
@onready var take_damage_sound: AudioStreamPlayer3D = %TakeDamageSound
@onready var take_damage_sound_2: AudioStreamPlayer3D = %TakeDamageSound2
var totalDamage : float
var coneDamage: float
var omniLightDamage : float = 0.0
var combindedDamage = coneDamage + omniLightDamage
var takingDaming : bool 
var startingHealth
@onready var basic_sound: AudioStreamPlayer3D = %BasicSound
var baseSpeed
var stopConeTween : Tween
var stopAOEtween : Tween



func _ready() -> void:
	baseSpeed = speed
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
		takingDaming = true
		takeDamage(delta)
		if CrystalManager.getEffectStrength(ItemData.EffectTypes.SlowEnemy) > 1.0:
			speed = baseSpeed
			var newSPeed = baseSpeed / CrystalManager.getEffectStrength(ItemData.EffectTypes.SlowEnemy)
			speed = newSPeed
		else:
			speed= baseSpeed
	else:
		stopTakeDamageSound()
		#print(health)
	if LanternManager.isInOmniLight(global_position) == true:
		if CrystalManager.getEffectStrength(ItemData.EffectTypes.aoeDamage) > 1.0:
			takingDaming = true
			takeAOEdamage(delta)
	else:
		stopTakingAOEDamageSound()
	if LanternManager.isInCone(global_position) == false and LanternManager.isInOmniLight(global_position) == false:
		takingDaming = false
		stopTakeDamageSound()
		stopTakingAOEDamageSound()
		speed = baseSpeed
	if health <= 0:
		set_physics_process(false)
		var tween = create_tween()
		tween.tween_property(get_node("GhostMesh"), "transparency", 1.0,1.0)
		takingDaming = false
		basic_sound.stop()
		death_sound.play()
		death_sound.finished.connect(death)
	

func onBodyEntered(body):
	print("hit:", body)
	if body is Player:
		var tween = create_tween()
		tween.tween_property(get_node("GhostMesh"), "transparency", 1.0,1.0)
		body.takeDamage(damage / CrystalManager.getEffectStrength(ItemData.EffectTypes.DamageReduct))
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
	var damageColor : Color

	if shorestDist >= tolerance:
		if shorestDist < 0.62 and shorestDist > 0.38:
			cDamage = startingHealth * 0.2
			damageColor = Color.GREEN
		else:
			cDamage = startingHealth * 0.08
			damageColor = Color.YELLOW
		totalDamage = ((eDamage + rDamage + aDamage + cDamage) * damageMult) * delta * 	CrystalManager.getEffectStrength(ItemData.EffectTypes.DoubleALLDamage)
		coneDamage = ((eDamage + rDamage + aDamage + cDamage) * damageMult) * delta
		health -= totalDamage
	else:
		cDamage = 0.0
		totalDamage = ((eDamage + rDamage + aDamage + cDamage) * damageMult) * delta * 	CrystalManager.getEffectStrength(ItemData.EffectTypes.DoubleALLDamage)
		health -= totalDamage
		coneDamage = ((eDamage + rDamage + aDamage + cDamage) * 0.4 * damageMult) * delta
		damageColor = Color.RED
	
	updateTakeDamageSound(totalDamage)
	labelCooldown -= delta
	if labelCooldown <= 0.0:
		spawnDamageLabel(totalDamage, damageColor)
		labelCooldown = 0.23
	print(cDamage)


func updateTakeDamageSound(damageAmount:float):
	print("Updating sound - damage: ", damageAmount, " playing: ", take_damage_sound.playing)
	if take_damage_sound.playing == false:
		take_damage_sound.play()
	var minDamage = 0.0
	var maxDamage = 3.0
	var intensity = remap(damageAmount, minDamage, maxDamage, 0.0, 1.0)
	take_damage_sound.pitch_scale = lerp(1.0, 2.7, intensity)
	take_damage_sound.volume_db = lerp(-6.0, 0.0, intensity)
	
func updateTakeDamageAOESound(damageAmount:float):
	if take_damage_sound_2.playing == false:
		take_damage_sound_2.play()
	var minDamage = 0.0
	var maxDamage = 3.0
	var intensity = remap(damageAmount, minDamage, maxDamage, 0.0, 1.0)
	take_damage_sound_2.pitch_scale = lerp(0.8, 2.0, intensity)
	take_damage_sound_2.volume_db = lerp(-10.0, -4.0, intensity)
	
	
	
func stopTakeDamageSound():
	if take_damage_sound.playing:
		if stopConeTween and stopConeTween.is_running():
			return
		stopConeTween = create_tween()
		stopConeTween.tween_property(take_damage_sound,"volume_db", -40, 3.0)
		stopConeTween.finished.connect(func():
			take_damage_sound.stop())

func stopTakingAOEDamageSound():
	if take_damage_sound_2.playing:
		if stopAOEtween and stopAOEtween.is_running():
			return
		stopAOEtween = create_tween()
		stopAOEtween.tween_property(take_damage_sound_2,"volume_db", -40, 3.0)
		stopAOEtween.finished.connect(func():
			take_damage_sound_2.stop())
func spawnDamageLabel(amount : int, color : Color):
	var label = damageLabelScene.instantiate()
	get_tree().root.add_child(label)
	label.global_position = global_position + Vector3(0,1,0)
	label.text = "-" + str(snapped(amount, 0.01))
	label.modulate = color

func takeAOEdamage(delta: float):
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
	var damageColor : Color
	if shorestDist >= tolerance:
		if shorestDist < 0.62 and shorestDist > 0.38:
			cDamage = startingHealth * 0.2
		else:
			cDamage = startingHealth * 0.08
		totalDamage = ((eDamage + rDamage + aDamage + cDamage) * damageMult) * delta * 	CrystalManager.getEffectStrength(ItemData.EffectTypes.DoubleALLDamage)
		health -= totalDamage *0.8
	else:
		cDamage = 0.0
		totalDamage = ((eDamage + rDamage + aDamage + cDamage) * damageMult) * delta * 	CrystalManager.getEffectStrength(ItemData.EffectTypes.DoubleALLDamage)
		health -= totalDamage * 0.8
	damageColor = Color.RED
	updateTakeDamageAOESound(totalDamage)
	labelCooldown -= delta
	if labelCooldown <= 0.0:
		spawnDamageLabel(totalDamage, damageColor)
		labelCooldown = 0.23
