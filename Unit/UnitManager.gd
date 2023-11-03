extends Node2D
class_name UnitManager

var loadPreviewWorker = preload("res://UI/HUD/SelectionBox/selected_unit_worker.tscn")

func _ready():
	DeselectAll()


func _process(_delta):
	# Move command
	if (Input.is_action_just_released("RightClick")):
		# Perform raycast for building in position
		var mouse_pos = get_global_mouse_position()
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.collision_mask = 8
		query.position = mouse_pos
		var result = space_state.intersect_point(query)
		var building = null
		if result:
			building = result[0].collider.get_parent()
			if !(building is Building):
				building = null

		for child in get_children():
			var unitController = child.get_node("UnitController")
			if !unitController:
				continue

			if !unitController.selected:
				continue

			if building && building == unitController.occupyingBuilding:
				continue

			if building && building.has_node("EnterArea") && building.visibleUnits.has(child):
				building.AddUnitToBuilding(child)
				
			unitController.MoveCommand(mouse_pos, building)



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

