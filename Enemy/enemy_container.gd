class_name GhostContainer
extends Node3D

@export var enemyScene : PackedScene 
@export var spawnInterval : float 
@onready var timer: Timer = %Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(onTimeOut)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if EnemyManager.currentPlayer != null:
		if InventoryManager.getFilledSlotsCount() >= 1:
			if timer.is_stopped():
				timer.start(5)

func onTimeOut():
	if EnemyManager.currentPlayer != null:
		spawnEnemy(enemyScene)
		timer.start(12)


func spawnEnemy(enemyScene):
	if enemyScene != null:
		var playerPos=EnemyManager.getPlayerPosition()
		var randAngleNumber= randf_range(0, 360)
		var randAngleInRads = deg_to_rad(randAngleNumber)
		var randDirection = Vector3(cos(randAngleInRads), 0, sin(randAngleInRads))
		var randDist = randf_range(20,40) 
		var randPostion = playerPos + (randDirection * randDist)
		var enemyChild = enemyScene.instantiate()
		self.add_child(enemyChild)
		enemyChild.global_position = randPostion
