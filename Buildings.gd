extends Node2D

var currentBuilding
var buildmenutoggle = false
var phantom_building = []
var buildingPreloads = {
	"House": preload("res://Buildings/house.tscn"), 
	
	"LumberCamp": preload("res://Buildings/lumber_camp.tscn"),
	"MiningCamp": preload("res://Buildings/mining_camp.tscn"),
	"Farm": preload("res://Buildings/farm.tscn"),
	"TownCenter": preload("res://Buildings/town_center.tscn"),
	"Barracks": preload("res://Buildings/barracks.tscn")
}
@onready var resourceManager = $"../resourceManager" 
# Called every frame. 'delta' is the elapsed time since the previous frame.
enum { GOLD, WOOD, STONE, FOOD }

func _process(delta):
	#buildingHotkey

	var res 

	if (Input.is_action_just_released("BuildMenu")):
		buildmenutoggle = !buildmenutoggle
		print("open build menu",buildmenutoggle)
	
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
		
	if justPressed:
		buildmenutoggle = false
		
		if (resourceManager.check(resourceManager.GOLD, currentBuilding["BuildingGold"]) && 
		resourceManager.check(resourceManager.WOOD, currentBuilding["BuildingWood"]) && 
		resourceManager.check(resourceManager.STONE, currentBuilding["BuildingStone"]) && 
		resourceManager.check(resourceManager.FOOD, currentBuilding["BuildingFood"])):

			print("gold used:", currentBuilding["BuildingGold"], resourceManager.use(resourceManager.GOLD, currentBuilding["BuildingGold"]))
			print(" wood used:", currentBuilding["BuildingWood"], resourceManager.use(resourceManager.WOOD, currentBuilding["BuildingWood"]))
			print(" stone used:", currentBuilding["BuildingStone"], resourceManager.use(resourceManager.STONE, currentBuilding["BuildingStone"]))
			print(" food used:", currentBuilding["BuildingFood"], resourceManager.use(resourceManager.FOOD, currentBuilding["BuildingFood"]))
			#buildingPlacement(currentBuilding)

			var building = res.instantiate()
			building.position = get_global_mouse_position()
			add_child(building)

		else: 
			print("not enough resources")
		
	pass

# func _input(event):
# 	if buildmenutoggle && currentBuilding:
# 		var mouse_position = get_global_mouse_position()
# 		phantom_building.position = mouse_position
# 		if event.is_action_pressed("mouse_left"):
# 			if (resourceManager.check(resourceManager.GOLD, currentBuilding["BuildingGold"]) && 
# 				resourceManager.check(resourceManager.WOOD, currentBuilding["BuildingWood"]) && 
# 				resourceManager.check(resourceManager.STONE, currentBuilding["BuildingStone"]) && 
# 				resourceManager.check(resourceManager.FOOD, currentBuilding["BuildingFood"])):
				
# 				# Create the actual building at the position of the phantom building
# 				var new_building = currentBuilding.instance()
# 				new_building.position = phantom_building.position
# 				get_parent().add_child(new_building)
				
# 				# Remove the phantom building
# 				phantom_building.queue_free()
				
# 				# Deduct the resources
# 				print("gold used:", currentBuilding["BuildingGold"], resourceManager.use(resourceManager.GOLD, currentBuilding["BuildingGold"]))
# 				print("wood used:", currentBuilding["BuildingWood"], resourceManager.use(resourceManager.WOOD, currentBuilding["BuildingWood"]))
# 				print("stone used:", currentBuilding["BuildingStone"], resourceManager.use(resourceManager.STONE, currentBuilding["BuildingStone"]))
# 				print("food used:", currentBuilding["BuildingFood"], resourceManager.use(resourceManager.FOOD, currentBuilding["BuildingFood"]))
				
# 			else:
# 				print("Not enough resources")


