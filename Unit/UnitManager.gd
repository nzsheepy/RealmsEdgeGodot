extends Node2D
class_name UnitManager

var loadPreviewWorker = preload("res://UI/HUD/SelectionBox/selected_unit_worker.tscn")

func _ready():
	DeselectAll()


func DeselectAll():
	for child in get_children():
		if child.has_node("UnitController"):
			child.get_node("UnitController").set_selected(false)


func unitSelected():
	var selected_units = []
	for child in get_children():
		if child.has_node("UnitController"):
			if child.get_node("UnitController").selected:
				selected_units.append(child)

	if selected_units.size() > 0:
		# Clear previous selection
		for child in get_node("../HUD/HUD/UnitGridContainer").get_children():
			child.queue_free()

		# Add new selection
		for unit in selected_units:
			var unitSelection = loadPreviewWorker.instantiate()
			get_node("../HUD/HUD/UnitGridContainer").add_child(unitSelection)
	else:
		# If no units are selected, clear the selection box
		for child in get_node("../HUD/HUD/UnitGridContainer").get_children():
			child.queue_free()

