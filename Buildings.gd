extends Node2D

class_name CurrentBuilding
var currentBuilding
var buildmenutoggle = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#buildingHotkey
	if (Input.is_action_just_released("BuildMenu")):
		buildmenutoggle = !buildmenutoggle
		print("build",buildmenutoggle)
	
	if (buildmenutoggle == false):
		return
	var justPressed = false
	#hotkey q
	if (Input.is_action_just_released("HouseHotkey")):
		currentBuilding = ImportData.buildingdata["House"]
		justPressed = true
		
	#hotkey w
	if (Input.is_action_just_released("LumberHotkey")):
		currentBuilding = ImportData.buildingdata["LumberCamp"]
		justPressed = true
		
	#hotkey e
	if (Input.is_action_just_released("MiningHotkey")):
		currentBuilding = ImportData.buildingdata["MiningCamp"]
		justPressed = true
		
	#hotkey r
	if (Input.is_action_just_released("FarmHotkey")):
		currentBuilding = ImportData.buildingdata["Farm"]
		justPressed = true
		
	#hotkey a
	if (Input.is_action_just_released("TownHotkey")):
		currentBuilding = ImportData.buildingdata["TownCenter"]
		justPressed = true
		
	#hotkey s
	if (Input.is_action_just_released("BarracksHotkey")):
		currentBuilding = ImportData.buildingdata["Barracks"]
		justPressed = true
		
	#if (use(gold,currentBuilding["GoldCost"]) && use(wood,currentBuilding["WoodCost"]) && 
	#use(stone,currentBuilding["StoneCost"]) && use(Food,currentBuilding["FoodCost"])):
		#buildingPlacement(currentBuilding)
		
	if (justPressed):
		buildmenutoggle = false
		print (currentBuilding["BuildingGold"])
	pass
