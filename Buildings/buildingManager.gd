#current buildingManger almost working

extends Node2D
class_name Building

@onready var resourceManager = $"../../resourceManager"
@onready var grid : Grid = $"../../Grid"
@onready var enemySpanwer = $"../../EnemySpawner"

@export var buildingSize: int
@export var overrideBuildingSize : int = -1
@export var resource: ResourceManager.ResourceType
@export var gatherAmount: int
@export var gatherTime: int
@export var buildingType : String
@export var noUnitsRequired : bool = false
var loadUnit = preload("res://Unit/unit.tscn")
var firstloop = true
@export var built = false
var isFoundation = false
@export var buildTime : int
var visibleUnits = []
var gatherProgress = 0
var can_train_worker = true

@onready var constructionProgressLabel = get_node("BuildingConstructionPercent")
@onready var healthPercent = get_node("healthPercent")
@onready var gatherRate = get_node("GatherRate")

@onready var constructionProgressBar = get_node("TextureProgressBar")
@onready var healthBar = get_node("TexturehealthBar")

@onready var burning = get_node("Damaged")
# Variable to keep track of time since the last resource gathering event
var elapsedTime = 0
var buildingTime = 0
var unitsGathering = []
var unitMask = 0

var unit_data_worker = ImportData.unitdata["Worker"]
var unit_data_solder = ImportData.unitdata["Solder"]

@export var buildingHealth: int = 1000
@onready var currentHealth: int = buildingHealth

@export_group("Barracks")
@onready var isBarracks : bool = buildingType == "Barracks"

@export var trainingTime : int = 10
var unitsToTrain = {}
var soldierPreload = preload("res://Unit/Soldier.tscn")
var totalResourceOnceCompleted = 0




func _ready():
	if buildingType in ImportData.buildingdata and "ConstructionTime" in ImportData.buildingdata[buildingType]:
		buildTime = ImportData.buildingdata[buildingType]["ConstructionTime"]
	else:
		print("Warning: Building type not found or ConstructionTime not set for", buildingType)
		buildTime = 0  # Set to a default value or handle this case as needed
	if "BuildingHealth" in ImportData.buildingdata[buildingType]:
		buildingHealth = ImportData.buildingdata[buildingType]["BuildingHealth"]
		currentHealth = buildingHealth
	else:
		print("Warning: BuildingHealth not set for", buildingType)
		buildingHealth = 1000  # Set to a default value or handle this case as needed
		currentHealth = buildingHealth

	if "GatherSpeed" in ImportData.buildingdata[buildingType]:
		gatherTime = ImportData.buildingdata[buildingType]["GatherSpeed"]
	else:
		print("Warning: GatherSpeed not set for", buildingType)
		gatherTime = 1.0  # Set to a default value or handle this case as needed

	if "GatherAmount" in ImportData.buildingdata[buildingType]:
		gatherAmount = ImportData.buildingdata[buildingType]["GatherAmount"]
	else:
		print("Warning: GatherAmount not set for", buildingType)
		gatherAmount = 1  # Set to a default value or handle this case as needed

		# Set the training time for barracks based on the GatherSpeed from ImportData
	if isBarracks and "GatherSpeed" in ImportData.buildingdata[buildingType]:
		trainingTime = ImportData.buildingdata[buildingType]["GatherSpeed"]
	else:
		print("Warning: GatherSpeed not set for", buildingType)
		trainingTime = 10  # Set to a default value or handle this case as needed

	burning.hide()
	var foundation = get_node("Foundation")
	if foundation:
		foundation.visible = false
	gatherRate.hide()
	constructionProgressLabel.hide()
	updateHealthPercentLabel()
	updateProgress()


func startBuild():
	# Prevent units from entering the building
	var area :Area2D = get_node("EnterArea")
	if area:
		area.set("scale", Vector2(0, 0))

	isFoundation = true
	self_modulate = Color(1, 1, 1, 0)
	var foundation = get_node("Foundation")
	if foundation:
		foundation.visible = true
		constructionProgressLabel.show()


func _process(delta):
	if isFoundation:
		# Handle foundation logic
		buildingTime += delta
		var progress = int(min(buildingTime / buildTime, 1.0) * 100)
		constructionProgressBar.value = progress
		constructionProgressLabel.text = str(progress) + "%" + " (" + str(buildTime) + "s)"

		if buildingTime >= buildTime:
			constructionCompleted()
			built = true
			isFoundation = false
			updateProgress()  # Update UI after construction is completed

		return  # Skip the rest of the process if still in foundation

	if not built:
		return  # If not built and not in foundation, skip the rest of the process

	elapsedTime += delta

	if firstloop and buildingType == "House":
		resourceManager.add(ResourceManager.ResourceType.MAXPOP, 5)
		firstloop = false

	if isBarracks:
		HandleBarracks()
	if buildingType == "TownCenter":
		HandleTownCenter()
		if can_train_worker:
			updateProgress()
	else:
		# Handle resource gathering for other building types
		if unitsGathering.size() == 0 and !noUnitsRequired:
			elapsedTime = 0  # Reset the timer if no units are gathering and it's required
		elif elapsedTime >= gatherTime:
			elapsedTime = 0  # Reset the timer
			var totalResource = gatherAmount * (unitsGathering.size() if not noUnitsRequired else 1)
			resourceManager.add(resource, totalResource)

	updateProgress()  # Update UI elements at the end of the process



func constructionCompleted():
	built = true
	isFoundation = false
	self_modulate = Color(1, 1, 1, 1)
	var foundation = get_node("Foundation")
	if foundation:
		foundation.visible = false
	constructionProgressLabel.hide()
	updateProgress()  # This will now correctly show the gather rate label since 'built' is true

var lastUnitsToTrainSize = 0  # Add this at the class level

func updateProgress():
	if isFoundation:
		var progress = int(min(buildingTime / buildTime, 1.0) * 100)
		constructionProgressBar.value = progress
		gatherRate.text = "Construction: %d%%" % progress
	elif isBarracks:
		if unitsToTrain.size() > 0:
			if unitsToTrain.size() != lastUnitsToTrainSize:
				elapsedTime = 0
				lastUnitsToTrainSize = unitsToTrain.size()
			var training_progress = elapsedTime / float(trainingTime)
			var progress = int(training_progress * 100)
			constructionProgressBar.value = progress
			if progress >= 100:
				constructionProgressBar.value = 0
				gatherRate.text = "Training: 100%"
				print("Training completed in: ", elapsedTime, " seconds.")
				elapsedTime = 0  # Reset elapsedTime after training is complete
			else:
				gatherRate.text = "Training: %d%%" % progress
		else:
			constructionProgressBar.value = 0
			gatherRate.text = "Training: 0%"
	elif buildingType == "TownCenter":
		if not can_train_worker:
			constructionProgressBar.value = 0
			gatherRate.text = "Cannot train Worker: Insufficient resources or population"
		else:
			var percentage_time_completed = int((elapsedTime / gatherTime) * 100)
			if percentage_time_completed >= 100:
				# If training is complete, reset the progress bar and elapsedTime
				constructionProgressBar.value = 0
				elapsedTime = 0
				gatherRate.text = "Worker ready for training"
				# Do not proceed to fill the bar again until HandleTownCenter updates can_train_worker
			else:
				constructionProgressBar.value = percentage_time_completed
				gatherRate.text = "Training: %d%%" % percentage_time_completed
	else:
		var totalResource = calculateTotalResourceOnceCompleted()
		if totalResource > 0:
			var percentage_time_completed = int((elapsedTime / gatherTime) * 100)
			constructionProgressBar.value = percentage_time_completed
			gatherRate.text = "%d%%, + %d" % [percentage_time_completed, totalResource]
		else:
			constructionProgressBar.value = 0
			gatherRate.text = "Place Worker To gather 0%"

	# Decide whether to show or hide the gatherRate label
	if built and not isFoundation:
		gatherRate.show()
	else:
		gatherRate.hide()

func calculateTotalResourceOnceCompleted() -> int:
	if isFoundation or not resourceManager.check(resource, 1):
		return 0  # No resources to gather or still under construction
	var totalResource = gatherAmount * unitsGathering.size()
	if noUnitsRequired:
		totalResource = gatherAmount
	return totalResource

func HandleTownCenter():
	can_train_worker = resourceManager.check(ResourceManager.ResourceType.POP, 1) and can_afford_unit(unit_data_worker)
	if elapsedTime >= gatherTime:
		elapsedTime = 0 # Reset the timer
		# Check if there's enough food and population to train a worker
		var can_afford_food = resourceManager.check(ResourceManager.ResourceType.FOOD, unit_data_worker["UnitFoodCost"])
		var has_population_space = resourceManager.check(ResourceManager.ResourceType.POP, 1)

		if can_afford_food and has_population_space and unitsGathering.size() < buildingSize * buildingSize:
			var new_pos = GetNewUnitPosition()
			if new_pos.x != -1 and new_pos.y != -1:
				purchase_unit(unit_data_worker)  # Deduct the resources for the unit
				var unit = loadUnit.instantiate()
				unit.get_node("UnitController").pathingToBuilding = self
				get_node("../../Units").add_child(unit)
				AddUnitToBuilding(unit)
				unit.get_node("StateController").SetState(StateController.State.MOVING)
				# Increase population here, after the unit is successfully created
				resourceManager.add(ResourceManager.ResourceType.POP, 1)
				elapsedTime = 0  # Reset the timer after successful unit creation
				can_train_worker = resourceManager.check(ResourceManager.ResourceType.POP, 1) and can_afford_unit(unit_data_worker)
		else:
			print("Not enough resources to create a worker.")
			can_train_worker = false
			elapsedTime = 0  # Reset the timer since we can't proceed with training



func HandleBarracks():
	for unit in unitsToTrain:
		if unitsToTrain[unit] <= elapsedTime:
			# Unit is done training, add it to the building
			RemoveUnitFromBuilding(unit)
			unit.Destroy(false)

			# Spawn a new soldier and add it to the building
			var soldier = soldierPreload.instantiate()
			soldier.get_node("UnitController").pathingToBuilding = self
			get_node("../../Units").add_child(soldier)
			resourceManager.add(ResourceManager.ResourceType.POP, 1)

			soldier.get_node("UnitController").canEnterBuildings = true
			AddUnitToBuilding(soldier)
			

func GetNewUnitPosition():
	var unitCount = unitsGathering.size()

	if isBarracks:
		unitCount = unitsToTrain.size()

	var realBuildingSize = buildingSize
	if overrideBuildingSize != -1:
		realBuildingSize = overrideBuildingSize

	if unitCount >= realBuildingSize * realBuildingSize:
		return Vector2(-1, -1)

	var tile_pos = Vector2(unitCount % realBuildingSize, unitCount / realBuildingSize)

	var offset = Vector2(0, 0)
	if overrideBuildingSize != -1:
		var offsetTileSize = (abs(buildingSize - realBuildingSize) / 2) * 16
		offset = Vector2(offsetTileSize, offsetTileSize)

	return global_position + tile_pos * 16 + Vector2(8, 8) + offset


func AddUnitToBuilding(newUnit):
	var stateController = newUnit.get_node("StateController")
	var unitsCount = unitsGathering.size()

	if isBarracks:
		unitsCount = unitsToTrain.size()

	if !stateController.isSoldier:
		visibleUnits.append(newUnit)

	# Save old unit mask
	unitMask = newUnit.collision_mask

	var realBuildingSize = buildingSize
	if overrideBuildingSize != -1:
		realBuildingSize = overrideBuildingSize

	if unitsCount >= realBuildingSize * realBuildingSize:
		return

	var new_pos = GetNewUnitPosition()

	if new_pos.x == -1 || new_pos.y == -1:
		return

	var unitController: UnitController = newUnit.get_node("UnitController")

	if !unitController.CanEnterBuilding(self):
		return

	if stateController:
		if isBarracks:
			unitsToTrain[newUnit] = elapsedTime + trainingTime
		else:
			unitsGathering.append(newUnit)

		stateController.SetState(StateController.State.GATHERING)

		unitController.set_selected(false)
		unitController.SetBuilding(self)

		# Disable layermasks
		newUnit.collision_mask = 0
		newUnit.collision_layer = 512

		# Disable NavAgent
		var navAgent : NavigationAgent2D = newUnit.get_node("NavigationAgent2D")
		navAgent.avoidance_enabled = false
		newUnit.position = new_pos
	
	updateProgress()


func FindSurroundingGrassTiles():
	var grass_tiles = []

	for x in range(-1, buildingSize + 1):
		for y in range(-1, buildingSize + 1):
			# Skip if corner
			if (x == -1 && y == -1) || (x == -1 && y == buildingSize) || (x == buildingSize && y == -1) || (x == buildingSize && y == buildingSize):
				continue

			# Skip if tile inside
			if x >= 0 && x < buildingSize && y >= 0 && y < buildingSize:
				continue

			var pos = global_position + Vector2(x, y) * 16 + Vector2(8, 8)
			var tile_pos = grid.WorldToTilePos(pos)
			if grid.TileBlocked(tile_pos):
				continue

			grass_tiles.append(pos)

	return grass_tiles


func FindExitPosition():
	var mouse_pos = get_global_mouse_position()
	var grass_tiles = FindSurroundingGrassTiles()

	if grass_tiles.size() == 0:
		return global_position

	var closest_tile = grass_tiles[0]
	var closest_dist = (mouse_pos - closest_tile).length_squared()
	for tile in grass_tiles:
		var dist = (mouse_pos - tile).length_squared()
		if dist < closest_dist:
			closest_dist = dist
			closest_tile = tile

	return closest_tile


func RemoveUnitFromBuilding(unit):
	visibleUnits.erase(unit)

	var realBuildingSize = buildingSize
	if overrideBuildingSize != -1:
		realBuildingSize = overrideBuildingSize

	# Find new safe position for unit outside of building
	var new_pos = FindExitPosition()
	unit.position = new_pos

	if isBarracks:
		unitsToTrain.erase(unit)
		if unit.get_node("StateController").isSoldier:
			unit.get_node("UnitController").canEnterBuildings = false
	else:
		unitsGathering.erase(unit)
	
	unit.collision_mask = unitMask
	unit.collision_layer = 514

	var stateController: StateController = unit.get_node("StateController")
	stateController.SetState(StateController.State.MOVING)

	# Enable NavAgent
	var navAgent : NavigationAgent2D = unit.get_node("NavigationAgent2D")
	navAgent.avoidance_enabled = true

	var unitsCount = unitsGathering.size()
	if isBarracks:
		unitsCount = unitsToTrain.size()

	# Reset position of current units
	var units = unitsGathering

	if isBarracks:
		units = unitsToTrain

	var i = 0
	for u in units:
		var tile_pos = Vector2(i % realBuildingSize, i / realBuildingSize)
		u.position = global_position + tile_pos * 16 + Vector2(8, 8)
		i += 1

	updateProgress()

func _on_enter_area_body_entered(body:Node2D):
	if body.has_node("StateController"):
		AddUnitToBuilding(body)


func Heal(amount):
	currentHealth += amount
	if currentHealth > buildingHealth:
		currentHealth = buildingHealth


func TakeDamage(damage):
	currentHealth -= damage
	updateHealthPercentLabel()

	var units = unitsGathering
	if isBarracks:
		units = unitsToTrain

	if currentHealth <= 0:
		for unit in units:
			unit.Destroy()
		enemySpanwer.spawnEnemy(global_position)
		queue_free()
		if buildingType == "House" && !isFoundation && built:
			resourceManager.add(ResourceManager.ResourceType.MAXPOP, -5)
		
func updateHealthPercentLabel():
	var health_percent = int((currentHealth / float(buildingHealth)) * 100)
	healthBar.hide()
	# Set the label's visibility based on the health percentage
	healthPercent.visible = health_percent < 80
	if health_percent < 95:
		healthBar.show()
	if health_percent < 40:
		burning.show()
	healthBar.value = health_percent
	# Update the label's text to show the current health
	healthPercent.text = "HP: %d/%d (%d%%)" % [currentHealth, buildingHealth, health_percent]

	
func can_afford_unit(unit_data: Dictionary) -> bool:
	return (
		resourceManager.check(ResourceManager.ResourceType.GOLD, unit_data["UnitGoldCost"]) &&
		resourceManager.check(ResourceManager.ResourceType.WOOD, unit_data["UnitWoodCost"]) &&
		resourceManager.check(ResourceManager.ResourceType.STONE, unit_data["UnitStoneCost"]) &&
		resourceManager.check(ResourceManager.ResourceType.FOOD, unit_data["UnitFoodCost"])
	)


func purchase_unit(unit_data: Dictionary):
	resourceManager.use(ResourceManager.ResourceType.GOLD, unit_data["UnitGoldCost"])
	resourceManager.use(ResourceManager.ResourceType.WOOD, unit_data["UnitWoodCost"])
	resourceManager.use(ResourceManager.ResourceType.STONE, unit_data["UnitStoneCost"])
	resourceManager.use(ResourceManager.ResourceType.FOOD, unit_data["UnitFoodCost"])


