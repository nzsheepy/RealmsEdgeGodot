#working building manager for hotkeys but not buttons
#needbuutton for build menu
#workingcheck mark
extends Node2D

@export var grid : Grid
var currentBuilding
var res
var building
var setOpacity
var buildmenutoggle = false
var justPressed = false
var buildingPreloads = {
	"House": preload("res://Buildings/house.tscn"),
	"LumberCamp": preload("res://Buildings/lumber_camp.tscn"),
	"MiningCamp": preload("res://Buildings/mining_camp.tscn"),
	"Farm": preload("res://Buildings/farm.tscn"),
	"TownCenter": preload("res://Buildings/town_center.tscn"),
	"Barracks": preload("res://Buildings/barracks.tscn")
}

@onready var labelBuildingName = $"../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/LabelBuildingName"
@onready var labelBuildingdescription = $"../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/LabelBuildingDescription"
@onready var goldLabel = $"../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_gold"
@onready var woodlabel = $"../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_wood"
@onready var stoneLabel = $"../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_stone"
@onready var foodLabel = $"../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_food"

var buttonToHotkeyMap = {
	"HouseButton": "HouseHotkey",
	"LumberCampButton": "LumberCampHotkey",
	"MiningCampButton": "MiningCampHotkey",
	"FarmButton": "FarmHotkey",
	"TownCenterButton": "TownCenterHotkey",
	"BarracksButton": "BarracksHotkey"
}



@onready var mouseHandle = $"../mouseHandle"
@onready var resourceManager = $"../resourceManager"
var resourceType = ResourceManager.ResourceType

func _ready():
	button_hide()
	hide_button_tips()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if (Input.is_action_just_released("BuildMenu")):
		buildmenutoggle = !buildmenutoggle
		print("open build menu", buildmenutoggle)
		if buildmenutoggle == true:
			button_show()
		if (buildmenutoggle == false):
			remove_child(building)
			button_hide()

	if (buildmenutoggle == false):
		return

	var building_buttons = {
		"House": get_node("../HUD/HUD/BuildingGridContainer/house_button"),
		"LumberCamp": get_node("../HUD/HUD/BuildingGridContainer/lumber_camp_button"),
		"MiningCamp": get_node("../HUD/HUD/BuildingGridContainer/mining_camp_button"),
		"Farm": get_node("../HUD/HUD/BuildingGridContainer/farm_button"),
		"Barracks": get_node("../HUD/HUD/BuildingGridContainer/barracks_button"),
		"TownCenter": get_node("../HUD/HUD/BuildingGridContainer/town_center_button"),
	}

	for building_name in building_buttons.keys():
		var button = building_buttons[building_name]
		if button:
			var building_data = ImportData.buildingdata[building_name]
			var has_enough_resources = (
				resourceManager.check(resourceType.GOLD, building_data["BuildingGold"]) &&
				resourceManager.check(resourceType.WOOD, building_data["BuildingWood"]) &&
				resourceManager.check(resourceType.STONE, building_data["BuildingStone"]) &&
				resourceManager.check(resourceType.FOOD, building_data["BuildingFood"])
			)

			if has_enough_resources:
				button.modulate = Color(1, 1, 1, 1)  # Reset to default color
			else:
				button.modulate = Color(1, 0, 0, 1)  # Set to red
		else:
			print("Button for building %s is null" % building_name)

			
	processHotkeys()
	displayBuildingPreview()
	# Check for left-click to place the building

func processHotkeys():
	for button_name in buttonToHotkeyMap.keys():
		if Input.is_action_just_released(buttonToHotkeyMap[button_name]):
			var buildingKey = button_name.replace("Button", "")
			currentBuilding = ImportData.buildingdata[buildingKey]
			res = buildingPreloads[buildingKey]
			justPressed = true

func GetBuildings():
	var buildings = []
	for child in get_children():
		if child is Building:
			buildings.append(child)

	return buildings

func GetBuildingsOfType(buildingType):
	var buildings = []
	for child in get_children():
		if child is Building and child.buildingType == buildingType:
			buildings.append(child)

	return buildings

func displayBuildingPreview():
	if (mouseHandle.mouseBlocked):
		return
	
	if (currentBuilding != null): 
		var has_enough_resources = (resourceManager.check(resourceType.GOLD, currentBuilding["BuildingGold"]) &&
		resourceManager.check(resourceType.WOOD, currentBuilding["BuildingWood"]) &&
		resourceManager.check(resourceType.STONE, currentBuilding["BuildingStone"]) &&
		resourceManager.check(resourceType.FOOD, currentBuilding["BuildingFood"]))
		
		if has_enough_resources:
			if justPressed:
				remove_child(building)
				building = res.instantiate()
				building.modulate = Color(1, 1, 1, 0.5)
				add_child(building)
			#var offset = (building.buildingSize/2.0) * 16
		var tile_pos = grid.WorldToTilePos(get_global_mouse_position()) 
		var new_pos = grid.TileToWorldPos(tile_pos) #- Vector2(offset, offset)
		if building != null:
			building.position = new_pos
		if building != null and building.buildingSize != null:
			if canPlaceBuilding(tile_pos, building.buildingSize):
				building.modulate = Color(0.2, 1, 0.2, 0.5)
			else:
				building.modulate = Color(1, 0.2, 0.2, 0.5)

			if Input.is_action_just_pressed("LeftClick"):
				placeBuilding(tile_pos, building.buildingSize)
		else:
			justPressed = false  # Reset justPressed if the player doesn't have enough resources

func placeBuilding(tile_pos, buildingSize):
	if currentBuilding == null || building == null:
		return

	# Raycast check per tile of building size
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 8
	query.exclude = [building.get_node("BuildingArea")]

	for i in range(buildingSize):
		for j in range(buildingSize):
			var check_tile = building.global_position + Vector2(i * 16, j * 16) + Vector2(8, 8)
			query.position = check_tile
			var result = space_state.intersect_point(query)
			if result:
				return

	if grid.GetTilesTypeRange(tile_pos, tile_pos + Vector2(buildingSize -1,buildingSize - 1)) == currentBuilding["BuildingTerrain"]:
		print("gold used:", currentBuilding["BuildingGold"], resourceManager.use(resourceType.GOLD, currentBuilding["BuildingGold"]))
		print("wood used:", currentBuilding["BuildingWood"], resourceManager.use(resourceType.WOOD, currentBuilding["BuildingWood"]))
		print("stone used:", currentBuilding["BuildingStone"], resourceManager.use(resourceType.STONE, currentBuilding["BuildingStone"]))
		print("food used:", currentBuilding["BuildingFood"], resourceManager.use(resourceType.FOOD, currentBuilding["BuildingFood"]))

		building.modulate = Color(1, 1, 1, 1)
		building.built = true
		building.startBuild()
		add_child(building)
		building = null

		currentBuilding = null
		res = null

		buildmenutoggle = false
		button_hide()
		justPressed = false

func canPlaceBuilding(tile_pos, buildingSize):
	if currentBuilding == null || building == null:
		return false

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 8
	query.exclude = [building.get_node("BuildingArea")]

	for i in range(buildingSize):
		for j in range(buildingSize):
			var check_tile = building.global_position + Vector2(i * 16, j * 16) + Vector2(8, 8)
			query.position = check_tile
			var result = space_state.intersect_point(query)
			if result:
				return false

	if grid.GetTilesTypeRange(tile_pos, tile_pos + Vector2(buildingSize -1,buildingSize - 1)) != currentBuilding["BuildingTerrain"]:
		return false

	return true

# Define a function to handle UI button clicks
# Define a function to handle UI button clicks
func onBuildingButtonPressed(button_name: String):
	var buildingKey = button_name
	currentBuilding = ImportData.buildingdata[buildingKey]
	res = buildingPreloads[buildingKey]
	justPressed = true

	displayBuildingPreview()

# Connect this function to all your building buttons
func _on_house_button_pressed():
	onBuildingButtonPressed("House")

func _on_lumber_camp_button_pressed():
	onBuildingButtonPressed("LumberCamp")

func _on_mining_camp_button_pressed():
	onBuildingButtonPressed("MiningCamp")

func _on_farm_button_pressed():
	onBuildingButtonPressed("Farm")

func _on_town_center_button_pressed():
	onBuildingButtonPressed("TownCenter")

func _on_barracks_button_pressed():
	onBuildingButtonPressed("Barracks")

func _on_build_menu_button_pressed():
	buildmenutoggle  = !buildmenutoggle
	if buildmenutoggle == true:
		button_show()# Replace with function body.
	if (buildmenutoggle == false):
		remove_child(building)
		button_hide()
	



func button_show():
	get_node("../HUD/HUD/BuildingGridContainer/house_button").show()
	get_node("../HUD/HUD/BuildingGridContainer/lumber_camp_button").show()
	get_node("../HUD/HUD/BuildingGridContainer/mining_camp_button").show()
	get_node("../HUD/HUD/BuildingGridContainer/farm_button").show()
	get_node("../HUD/HUD/BuildingGridContainer/town_center_button").show()
	get_node("../HUD/HUD/BuildingGridContainer/barracks_button").show()
	get_node("../HUD/HUD/HBoxContainer/unit_attack_button").hide()
	get_node("../HUD/HUD/HBoxContainer/unit_move_button").hide()
	get_node("../HUD/HUD/HBoxContainer/unit_stop_button").hide()
	mouseHandle.show_resource_tips()
	


func button_hide():
	get_node("../HUD/HUD/BuildingGridContainer/house_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/lumber_camp_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/mining_camp_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/farm_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/town_center_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/barracks_button").hide()
	get_node("../HUD/HUD/HBoxContainer/unit_attack_button").show()
	get_node("../HUD/HUD/HBoxContainer/unit_move_button").show()
	get_node("../HUD/HUD/HBoxContainer/unit_stop_button").show()

func show_button_tips():
	get_node("../HUD/HUD/CommandCardBuildingTips").visible = true
func hide_button_tips():
	get_node("../HUD/HUD/CommandCardBuildingTips").visible = false

func _on_house_button_mouse_entered():
	show_button_tips()
	labelBuildingName.text = "House (hotkey: Q)" 
	goldLabel.text = str(ImportData.buildingdata["House"]["BuildingGold"])
	woodlabel.text = str(ImportData.buildingdata["House"]["BuildingWood"])
	stoneLabel.text = str(ImportData.buildingdata["House"]["BuildingStone"])
	foodLabel.text = str(ImportData.buildingdata["House"]["BuildingFood"])
	labelBuildingdescription.text = str(ImportData.buildingdata["House"]["BuildingHelpDesciption"])

func _on_house_button_mouse_exited():
	hide_button_tips()

func _on_lumber_camp_button_mouse_entered():
	show_button_tips()
	labelBuildingName.text = "Lumber Camp (hotkey: W)" 
	goldLabel.text = str(ImportData.buildingdata["LumberCamp"]["BuildingGold"])
	woodlabel.text = str(ImportData.buildingdata["LumberCamp"]["BuildingWood"])
	stoneLabel.text = str(ImportData.buildingdata["LumberCamp"]["BuildingStone"])
	foodLabel.text = str(ImportData.buildingdata["LumberCamp"]["BuildingFood"])
	labelBuildingdescription.text = str(ImportData.buildingdata["LumberCamp"]["BuildingHelpDesciption"])

func _on_lumber_camp_button_mouse_exited():
	hide_button_tips()

func _on_mining_camp_button_mouse_entered():
	show_button_tips()
	labelBuildingName.text = "Mining Camp (hotkey: E)" 
	goldLabel.text = str(ImportData.buildingdata["MiningCamp"]["BuildingGold"])
	woodlabel.text = str(ImportData.buildingdata["MiningCamp"]["BuildingWood"])
	stoneLabel.text = str(ImportData.buildingdata["MiningCamp"]["BuildingStone"])
	foodLabel.text = str(ImportData.buildingdata["MiningCamp"]["BuildingFood"])
	labelBuildingdescription.text = str(ImportData.buildingdata["MiningCamp"]["BuildingHelpDesciption"])

func _on_mining_camp_button_mouse_exited():
	hide_button_tips()

func _on_farm_button_mouse_entered():
	show_button_tips()
	labelBuildingName.text = "Farm (hotkey: A)" 
	goldLabel.text = str(ImportData.buildingdata["Farm"]["BuildingGold"])
	woodlabel.text = str(ImportData.buildingdata["Farm"]["BuildingWood"])
	stoneLabel.text = str(ImportData.buildingdata["Farm"]["BuildingStone"])
	foodLabel.text = str(ImportData.buildingdata["Farm"]["BuildingFood"])
	labelBuildingdescription.text = str(ImportData.buildingdata["Farm"]["BuildingHelpDesciption"])

func _on_farm_button_mouse_exited():
	hide_button_tips()

func _on_town_center_button_mouse_entered():
	show_button_tips()
	labelBuildingName.text = "Town Center (hotkey: S)" 
	goldLabel.text = str(ImportData.buildingdata["TownCenter"]["BuildingGold"])
	woodlabel.text = str(ImportData.buildingdata["TownCenter"]["BuildingWood"])
	stoneLabel.text = str(ImportData.buildingdata["TownCenter"]["BuildingStone"])
	foodLabel.text = str(ImportData.buildingdata["TownCenter"]["BuildingFood"])
	labelBuildingdescription.text = str(ImportData.buildingdata["TownCenter"]["BuildingHelpDesciption"])

func _on_town_center_button_mouse_exited():
	hide_button_tips()

func _on_barracks_button_mouse_entered():
	show_button_tips()
	labelBuildingName.text = "Barracks (hotkey: D)" 
	goldLabel.text = str(ImportData.buildingdata["Barracks"]["BuildingGold"])
	woodlabel.text = str(ImportData.buildingdata["Barracks"]["BuildingWood"])
	stoneLabel.text = str(ImportData.buildingdata["Barracks"]["BuildingStone"])
	foodLabel.text = str(ImportData.buildingdata["Barracks"]["BuildingFood"])
	labelBuildingdescription.text = str(ImportData.buildingdata["Barracks"]["BuildingHelpDesciption"])

func _on_barracks_button_mouse_exited():
	hide_button_tips()

