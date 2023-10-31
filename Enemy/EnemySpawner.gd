extends Node2D

var enemy = preload("res://Enemy/Enemy.tscn")

@export_group("Wave Spawn")
@export var waveAmount = 5
@export var waveWaitTime = 25.0

@export_group("Trickle Spawn")
@export var singleWaitTime = 2.0


var waveNumber = 0
var waveTimer = 0.0
var singleTimer = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	waveTimer += delta
	singleTimer += delta

	if waveTimer >= waveWaitTime:
		waveTimer = 0.0
		waveNumber += 1
		for i in range(waveAmount):
			var enemyInstance = enemy.instantiate()
			add_child(enemyInstance)
		
		print("Wave " + str(waveNumber) + " spawned")

	if singleTimer >= singleWaitTime:
		singleTimer = 0.0
		var enemyInstance = enemy.instantiate()
		add_child(enemyInstance)

		print("Enemy spawned")
