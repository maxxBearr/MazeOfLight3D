extends GhostEnemy
@onready var ghost_mesh: MeshInstance3D = %GhostMesh


func _ready() -> void:
	super()
	var colors = [Color.RED, Color.ORANGE_RED, Color.MEDIUM_VIOLET_RED, Color.BLUE, Color.SKY_BLUE, Color.CADET_BLUE, Color.GREEN, Color.MEDIUM_SPRING_GREEN, Color.LIGHT_SEA_GREEN]
	inherentColor = colors.pick_random()
	super()
