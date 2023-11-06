extends Node2D
class_name GameStateTracker

@export var towncenters = 1
@export var necromancers = 2
var gamedone = false


func _physics_process(_delta):
	if gamedone:
		return

	if towncenters == 0:
		gamedone = true
		get_tree().change_scene_to_file("res://Levels/GameOver.tscn")

	if necromancers == 0:
		gamedone = true
		get_tree().change_scene_to_file("res://Levels/GameWon.tscn")


func AddTowncenter():
	towncenters += 1

func RemoveTowncenter():
	towncenters -= 1


func AddNecromancer():
	necromancers += 1

func RemoveNecromancer():
	necromancers -= 1
