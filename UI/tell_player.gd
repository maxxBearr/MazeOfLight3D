class_name TellPlayer
extends RichTextLabel
@onready var camera : Camera3D = get_viewport().get_camera_3d()
var player : Player = null
signal textChanged(newText:String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UImanager.registerTellPlayerLabel(self)
	visible_ratio = 0.0
	player = get_tree().get_first_node_in_group("Player")
	printText("Use WASD to move
	Press/Hold Shift to change lantern color
	Find all of the crysyals and return here to escape with your finidings
	Hint: the world is reactive to light
	Also, dont die. ")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func printText(newText: String):
	text = newText
	var tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, 5.0)
	tween.finished.connect(onTweenFinished)

func _process(delta: float) -> void:
	if player and camera:
		var screenPos = camera.unproject_position(player.global_position + Vector3(5,-2,0))
		position = screenPos - size / 2 


func onTweenFinished():
	get_tree().create_timer(4.0).timeout.connect(func():
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 1.4)
)
