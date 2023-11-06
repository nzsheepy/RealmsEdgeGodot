extends Node2D
class_name GameStateTracker

var towncenters = []
@export var startingTownCenter : Building


func _ready():
	AddTowncenter(startingTownCenter)


func _physics_process(_delta):
	# if all town centers are destroyed, game over
	if len(towncenters) == 0:
		print("Game Over")


func AddTowncenter(towncenter):
	towncenters.append(towncenter)