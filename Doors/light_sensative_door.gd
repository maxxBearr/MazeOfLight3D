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
		updateShutterIntensity(shortestDist)
		if shortestDist <= tolerance:
					makeDoorDisapear()
	else:
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
		var tween = create_tween()
		tween.tween_property(door_01, "transparency", 1.0,0.3)
		tween.finished.connect(func():
			player_collision.disabled = true
			door_01.ignore_occlusion_culling = true )
			#print("player collsion disabled")

func makeDoorReappear():
	player_collision.disabled = false
	stopShutter()
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


func stopShutter():
	if shutterTween:
		shutterTween.kill()
		shutterTween = null
	position = basePosition
