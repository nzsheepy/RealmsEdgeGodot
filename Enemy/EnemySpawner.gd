extends Node2D

var enemy = preload("res://Enemy/Enemy.tscn")

@export var isNecrodancer = false
@export var canAutoSpawn = true

@export_group("Wave Spawn")
@export var waveAmount = 5
@export var waveWaitTime = 25.0

@export_group("Trickle Spawn")
@export var singleWaitTime = 2.0



var waveNumber = 0
var waveTimer = 0.0
var singleTimer = 0.0
var startTrickle = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func startwave():
	if !canAutoSpawn:
		return

	for i in range(waveAmount):
		spawnEnemy(global_position)
	
	print("Wave " + str(waveNumber) + " spawned")
	startTrickle = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !canAutoSpawn:
		return

	waveTimer += delta
	singleTimer += delta

	if startTrickle and singleTimer >= singleWaitTime:
		singleTimer = 0.0
		spawnEnemy(global_position)

		print("Enemy spawned")

func spawnEnemy(pos):
	var enemyInstance = enemy.instantiate()

	if isNecrodancer:
		var espawn = $"../../EnemySpawner"
		espawn.add_child(enemyInstance)
		var enemyController = enemyInstance.get_node("EnemyController")
		enemyController.necromancer = self
		enemyController.hasNecromancer = true
	else:
		add_child(enemyInstance)

	enemyInstance.global_position = pos
