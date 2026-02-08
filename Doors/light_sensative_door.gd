class_name LightSensativeDoor
extends Node3D
@onready var door_01: MeshInstance3D = %Door_01
@onready var static_for_player: StaticBody3D = %StaticForPlayer
@onready var player_collision: CollisionShape3D = %PlayerCollision
@onready var static_for_ray: StaticBody3D = %StaticForRay
@onready var ray_collision: CollisionShape3D = %RayCollision
@export var requiredColor : Color
var reapperTimer : float =0.0
var waitingToReapear : bool= false
@export var tolerance := 0.1
var basePosition : Vector3
var shutterTween : Tween
@onready var rumble_rock_sound: AudioStreamPlayer3D = %RumbleRockSound
var doorGone := false


func _ready() -> void:
	basePosition = position

func _physics_process(delta: float) -> void:
	if LanternManager.isInCone(global_position) == true:
		waitingToReapear = false
		reapperTimer = 0.0
		var lightHue = LanternManager.getCurrentColor().h 
		var directDist = abs(lightHue - requiredColor.h)
		var wrapDist = 1.0 - directDist
		var shortestDist = min(directDist, wrapDist)
		if doorGone == false:
			updateRockSound(shortestDist)
			updateShutterIntensity(shortestDist)
		
		
		if shortestDist <= tolerance:
				makeDoorDisapear()
	else:
		stopRockSound()
		stopShutter()
		if player_collision.disabled == true:
			if not waitingToReapear:
				waitingToReapear = true
				reapperTimer = 0.0
			reapperTimer += delta
			if reapperTimer >= 8.0:
				waitingToReapear = false
				reapperTimer = 0.0
				if LanternManager.isInOmniLight(global_position) == false:
					makeDoorReappear()


func makeDoorDisapear():
	if player_collision.disabled == false:
		doorGone = true
		stopRockSound()
		stopShutter()
		var tween = create_tween()
		tween.tween_property(door_01, "transparency", 1.0,0.3)
		tween.finished.connect(func():
			player_collision.disabled = true
			door_01.ignore_occlusion_culling = true )
			#print("player collsion disabled")

func makeDoorReappear():
	player_collision.disabled = false
	stopShutter()
	doorGone = false
	var tween = create_tween()
	tween.tween_property(door_01,"transparency", 0.3, 0.2)
	door_01.ignore_occlusion_culling = true
	#print("door reappeared")

func startJitterTween(jitterAmount:float, speed:float):
	if shutterTween:
		shutterTween.kill()
			
	shutterTween = create_tween().set_loops()
	shutterTween.tween_property(self,"position", basePosition + Vector3(
		randf_range(-jitterAmount, jitterAmount),
		randf_range(-jitterAmount, jitterAmount),
		0.0),speed)

func updateShutterIntensity(hueDistance: float):
	var maxDistance = 0.5
	var jitterAmount = remap(hueDistance, 0.0, maxDistance, 0.4, 0.05)
	var shutterSpeed = remap(hueDistance, 0.0, maxDistance, 0.05, 0.35)
	
	startJitterTween(jitterAmount, shutterSpeed)

func updateRockSound(hueDistance: float):
	if rumble_rock_sound.playing == false:
		if door_01.transparency < 0.8:
			rumble_rock_sound.play()
			var audioLenght = rumble_rock_sound.stream.get_length()
			var randomStart = randf_range(0.0, audioLenght)
			rumble_rock_sound.seek(randomStart)
	
	var intensity = remap(hueDistance,0.4, 0.05, 0.0, 1.0 )
	rumble_rock_sound.pitch_scale = lerp(1.0,4.0,intensity)
	rumble_rock_sound.volume_db = lerp(-30.0, -20.0, intensity)
	
func stopRockSound():
	if rumble_rock_sound.playing:
		rumble_rock_sound.stop()


func stopShutter():
	if shutterTween:
		shutterTween.kill()
		shutterTween = null
	position = basePosition
