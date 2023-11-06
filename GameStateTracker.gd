extends Node2D
class_name GameStateTracker

@export var towncenters = 1
var gamedone = false


func _physics_process(_delta):
	if gamedone:
		return

	if towncenters == 0:
		print("Game Over")
		gamedone = true


func AddTowncenter():
	towncenters += 1

func RemoveTowncenter():
	towncenters -= 1