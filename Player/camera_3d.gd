extends Camera3D

@export var target: Node3D
@export var offset := Vector3.ZERO
@export var smoothing := 8.0

func _ready():
	# Store current position relative to target as the offset
	if target:
		offset = global_position - target.global_position

func _physics_process(delta):
	if target:
		var target_pos = target.global_position + offset
		global_position = global_position.lerp(target_pos, smoothing * delta)
