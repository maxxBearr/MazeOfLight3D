class_name Player
extends CharacterBody3D

@export var SPEED = 5.0
@export var ROTATION_SPEED = 10.0
@export var maxhealth: int = 10
@export var currentHealth : int
@onready var camera : Camera3D = get_viewport().get_camera_3d()
@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var animPlayer = %UAL1/AnimationPlayer

signal healthChanged(newHealth:int)
func _ready() -> void:
	EnemyManager.registerPlayer(self)
	UImanager.registerPlayer(self)
	currentHealth = maxhealth


func _physics_process(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	rotate_toward_mouse()
	# Get input direction
	var input_dir := Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Rotate player to face movement direction
		var localDirection = direction.rotated(Vector3.UP, -rotation.y)
		updateAnimation(localDirection)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	

	move_and_slide()
	

func updateAnimation(localDir:Vector3):
	# local_dir.z > 0 means moving forward (relative to facing)
	# local_dir.z < 0 means moving backward
	# local_dir.x tells you left/right
	if abs(localDir.z) > abs(localDir.x):
		#Primarily forward/backwards
		if localDir.z > 0:
			playAnimation("Jog_Fwd") #forwad
		else:
			playAnimation("Jog_Bwd") #back
	else: 
		#strafing
		if localDir.x > 0:
			playAnimation("Jog_Right") # right
		else:
			playAnimation("Jog_Left") #left



func playAnimation(animName : String):
	if animPlayer.current_animation != animName:
		animPlayer.play(animName)

func takeDamage(amount: int):
	currentHealth -= amount
	healthChanged.emit(currentHealth)
	print(currentHealth)
	if currentHealth <= 0:
		GameEvents.playerDied.emit()
		
func pickUpItem (item: ItemData):
	GameEvents.itemPickedUp.emit(item)

func rotate_toward_mouse() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_normal = camera.project_ray_normal(mouse_pos)
	
	var plane = Plane(Vector3.UP, global_position.y)
	
	var intersection = plane.intersects_ray(ray_origin, ray_normal)
	
	if intersection:
		var opposite_point = global_position - (intersection - global_position)
		look_at(opposite_point)
