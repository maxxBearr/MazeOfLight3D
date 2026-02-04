extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 1.5, 1.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.finished.connect(queue_free)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
