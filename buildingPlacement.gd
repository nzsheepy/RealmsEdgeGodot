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
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerTipHouse").visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if (Input.is_action_just_released("BuildMenu")):
		buildmenutoggle = !buildmenutoggle
		print("open build menu", buildmenutoggle)
		if buildmenutoggle == true:
			button_show()#
		if (buildmenutoggle == false):
			remove_child(building)
			button_hide()

	if (buildmenutoggle == false):
		return

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
	
	if (currentBuilding != null && resourceManager.check(resourceType.GOLD, currentBuilding["BuildingGold"]) &&
		resourceManager.check(resourceType.WOOD, currentBuilding["BuildingWood"]) &&
		resourceManager.check(resourceType.STONE, currentBuilding["BuildingStone"]) &&
		resourceManager.check(resourceType.FOOD, currentBuilding["BuildingFood"])):

		if justPressed:
			remove_child(building)
			building = res.instantiate()
			building.modulate = Color(1, 1, 1, 0.5)
			add_child(building)
		#var offset = (building.buildingSize/2.0) * 16
		var tile_pos = grid.WorldToTilePos(get_global_mouse_position()) 
		var new_pos = grid.TileToWorldPos(tile_pos) #- Vector2(offset, offset) 
		building.position = new_pos

		if Input.is_action_just_released("LeftClick"):
			placeBuilding(tile_pos, building.buildingSize) 

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


func button_hide():
	get_node("../HUD/HUD/BuildingGridContainer/house_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/lumber_camp_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/mining_camp_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/farm_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/town_center_button").hide()
	get_node("../HUD/HUD/BuildingGridContainer/barracks_button").hide()

func _on_house_button_mouse_entered():
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerTipHouse").visible = true

func _on_house_button_mouse_exited():
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerTipHouse").visible = false
