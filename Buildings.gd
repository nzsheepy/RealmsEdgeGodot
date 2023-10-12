extends Node2D

var currentBuilding
var buildmenutoggle = false
@onready var resourceManager = $"../resourceManager" 
# Called every frame. 'delta' is the elapsed time since the previous frame.
enum { GOLD, WOOD, STONE, FOOD }

func _process(delta):
	#buildingHotkey
	if (Input.is_action_just_released("BuildMenu")):
		buildmenutoggle = !buildmenutoggle
		print("open build menu",buildmenutoggle)
	
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
		currentBuilding = ImportData.buildingdata["TownCenter"]
		justPressed = true
	#hotkey s
	if (Input.is_action_just_released("BarracksHotkey")):
		currentBuilding = ImportData.buildingdata["Barracks"]
		justPressed = true
		currentBuilding = ImportData.buildingdata["Barracks"]
		justPressed = true
	
	
	if (justPressed):
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
		else: 
			print("not enough resources")
		
	pass
