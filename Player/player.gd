class_name Player
extends CharacterBody3D

@export var SPEED = 5.0
@export var ROTATION_SPEED = 10.0
@export var maxhealth: float = 10.0
@export var currentHealth : float
@onready var camera : Camera3D = get_viewport().get_camera_3d()
@onready var omni_light_3d: OmniLight3D = %OmniLight3D
@onready var animTree = %RiggedAnimChar/AnimationTree
@onready var stateMachine = animTree.get("parameters/StateMachine/playback")
@onready var animPlayer = %RiggedAnimChar/AnimationPlayer
var currentAnim = ""
@onready var footsteps: AudioStreamPlayer3D = %Footsteps
var baseSpeed 
signal healthChanged(newHealth:int)
func _ready() -> void:
	
	EnemyManager.registerPlayer(self)
	UImanager.registerPlayer(self)
	currentHealth = maxhealth
	# Make sure AnimationTree is set up
	print("AnimTree anim_player: ", animTree.anim_player)
	print("AnimTree root node: ", animTree.get("root_node"))
	animTree.active = true
	baseSpeed = SPEED
	print("All parameters:")
	for prop in animTree.get_property_list():
		if prop.name.begins_with("parameters/"):
			print("  ", prop.name)


func _physics_process(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	rotate_toward_mouse()
	# Get input direction
	var input_dir := Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()

	if CrystalManager.getEffectStrength(ItemData.EffectTypes.WalkSpeed) > 1.0:
		SPEED = baseSpeed
		var newSPeed = baseSpeed * CrystalManager.getEffectStrength(ItemData.EffectTypes.WalkSpeed)
		SPEED = newSPeed
	else:
		SPEED = baseSpeed
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# Rotate player to face movement direction
		var localDirection = direction.rotated(Vector3.UP, -rotation.y)
		updateAnimation(localDirection)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		playAnimation("Idle")
	
	if velocity.length() > 0.1:
		if footsteps.playing == false:
			footsteps.play()
	else:
		footsteps.stop()
	move_and_slide()
	
	if CrystalManager.getEffectStrength(ItemData.EffectTypes.HealOverTime) > 1.0:
		currentHealth += delta * CrystalManager.getEffectStrength(ItemData.EffectTypes.HealOverTime) 
		currentHealth=  clamp(currentHealth, 0.0, maxhealth)
		



	

func updateAnimation(localDir:Vector3):
	var forwardBack = localDir.z
	var leftRight = localDir.x
	
	var isDiagonal : bool = abs(forwardBack) > 0.3 and abs(leftRight) > 0.3

	if isDiagonal and forwardBack < 0:
		if leftRight > 0:
			playAnimation("Jog_Bwd_R")
		else:
			playAnimation("Jog_Bwd_L")
	elif abs(forwardBack) > abs(leftRight):
		if forwardBack>0:
			playAnimation("Jog_Fwd")
		else:
			playAnimation("Jog_Bwd")
	else:
		if leftRight > 0:
			playAnimation("Jog_Right")
		else:
			playAnimation("Jog_Left")


func playAnimation(animName: String) -> void:
	if currentAnim != animName:
		currentAnim = animName
		animTree.set("parameters/Transition/transition_request", animName)
		print("PlayingP: ", animName)
		
func takeDamage(amount: float):
	if CrystalManager.getEffectStrength(ItemData.EffectTypes.DoubleALLDamage) > 1.0:
		amount *= 2.0
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
