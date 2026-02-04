extends Label
@onready var camera : Camera3D = get_viewport().get_camera_3d()
var player : Player = null
var isShowing := false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	GameEvents.showInteractPrompt.connect(onShowPrompt)
	GameEvents.hideInteractPrompt.connect(onHidePrompt)
	player = get_tree().get_first_node_in_group("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isShowing and player and camera:
		var screenPos = camera.unproject_position(player.global_position + Vector3(0,-2,0))
		position = screenPos - size / 2 


func onShowPrompt (prompt: String):
	text = prompt
	visible = true
	isShowing = true


func onHidePrompt():
	visible = false
	isShowing = false
