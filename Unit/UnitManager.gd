extends Node2D
class_name UnitManager


func _ready():
	DeselectAll()


func DeselectAll():
	for child in get_children():
		if child.has_node("UnitController"):
			child.get_node("UnitController").set_selected(false)
