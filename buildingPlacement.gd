extends Node2D

@export var grid : Grid
var currentBuilding
var res 
var building
var setOpacity
var buildmenutoggle = false
var buildingPreloads = {
	"House": preload("res://Buildings/house.tscn"), 
	"LumberCamp": preload("res://Buildings/lumber_camp.tscn"),
	"MiningCamp": preload("res://Buildings/mining_camp.tscn"),
	"Farm": preload("res://Buildings/farm.tscn"),
	"TownCenter": preload("res://Buildings/town_center.tscn"),
	"Barracks": preload("res://Buildings/barracks.tscn")
}


@onready var resourceManager = $"../resourceManager" 
var resourceType = ResourceManager.ResourceType


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_released("BuildMenu")):
		buildmenutoggle = !buildmenutoggle
		print("open build menu",buildmenutoggle)

		if (buildmenutoggle == false):
			remove_child(building)
	
	if (buildmenutoggle == false):
		return
		
	var justPressed = false

	#hotkey q
	if (Input.is_action_just_released("HouseHotkey")):
		currentBuilding = ImportData.buildingdata["House"]
		res = buildingPreloads["House"]
		justPressed = true
		
	#hotkey w
	if (Input.is_action_just_released("LumberHotkey")):
		currentBuilding = ImportData.buildingdata["LumberCamp"]
		res = buildingPreloads["LumberCamp"]
		justPressed = true
		
	#hotkey e
	if (Input.is_action_just_released("MiningHotkey")):
		currentBuilding = ImportData.buildingdata["MiningCamp"]
		res = buildingPreloads["MiningCamp"]
		justPressed = true
		
	#hotkey r
	if (Input.is_action_just_released("FarmHotkey")):
		currentBuilding = ImportData.buildingdata["Farm"]
		res = buildingPreloads["Farm"]
		justPressed = true
		
	#hotkey a
	if (Input.is_action_just_released("TownHotkey")):
		currentBuilding = ImportData.buildingdata["TownCenter"]
		res = buildingPreloads["TownCenter"]
		justPressed = true
		
	#hotkey s
	if (Input.is_action_just_released("BarracksHotkey")):
		currentBuilding = ImportData.buildingdata["Barracks"]
		res = buildingPreloads["Barracks"]
		justPressed = true


	if (currentBuilding != null && resourceManager.check(resourceType.GOLD, currentBuilding["BuildingGold"]) && 
		resourceManager.check(resourceType.WOOD, currentBuilding["BuildingWood"]) && 
		resourceManager.check(resourceType.STONE, currentBuilding["BuildingStone"]) && 
		resourceManager.check(resourceType.FOOD, currentBuilding["BuildingFood"])):		
		print("Left click to place building")

		if (justPressed == true):
			remove_child(building)
			building = res.instantiate()
			building.modulate = Color(1,1,1,0.5)
			add_child(building)

		# Snap to grid by converting to tile position and back
		var tile_pos = grid.WorldToTilePos(get_global_mouse_position())
		var new_pos = grid.TileToWorldPos(tile_pos)
		building.position = new_pos

		if (Input.is_action_just_released("LeftClick")):
			print("left click")
			print("gold used:", currentBuilding["BuildingGold"], resourceManager.use(resourceType.GOLD, currentBuilding["BuildingGold"]))
			print(" wood used:", currentBuilding["BuildingWood"], resourceManager.use(resourceType.WOOD, currentBuilding["BuildingWood"]))
			print(" stone used:", currentBuilding["BuildingStone"], resourceManager.use(resourceType.STONE, currentBuilding["BuildingStone"]))
			print(" food used:", currentBuilding["BuildingFood"], resourceManager.use(resourceType.FOOD, currentBuilding["BuildingFood"]))

			building.modulate = Color(1,1,1,1)
			add_child(building)
			building = null

			# forget the current building
			currentBuilding = null
			res = null

			buildmenutoggle = false
			justPressed = false

		else: 
			print("not enough resources")
