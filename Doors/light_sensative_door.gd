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

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if LanternManager.isInCone(global_position) == true:
		waitingToReapear = false
		reapperTimer = 0.0
		var lightHue = LanternManager.getCurrentColor().h 
		var directDist = abs(lightHue - requiredColor.h)
		var wrapDist = 1.0 - directDist
		var shorestDist = min(directDist, wrapDist)
		if shorestDist <= tolerance:
					makeDoorDisapear()
	else:
		if player_collision.disabled == true:
			if not waitingToReapear:
				waitingToReapear = true
				reapperTimer = 0.0
			reapperTimer += delta
			if reapperTimer >= 8.0:
				waitingToReapear = false
				reapperTimer = 0.0
				makeDoorReappear()


func makeDoorDisapear():
	if player_collision.disabled == false:
		var tween = create_tween()
		tween.tween_property(door_01, "transparency", 1.0,0.3)
		tween.finished.connect(func():
			player_collision.disabled = true
			door_01.ignore_occlusion_culling = true )
			#print("player collsion disabled"))

func makeDoorReappear():
	player_collision.disabled = false
	var tween = create_tween()
	tween.tween_property(door_01,"transparency", 0.3, 0.2)
	door_01.ignore_occlusion_culling = true
	#print("door reappeared")
