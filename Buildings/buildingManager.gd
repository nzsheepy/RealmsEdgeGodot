#current buildingManger

extends Node2D
class_name Building

@onready var resourceManager = $"../../resourceManager"
@onready var grid : Grid = $"../../Grid"

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

@onready var constructionProgressLabel = get_node("BuildingConstructionPercent")
@onready var healthPercent = get_node("healthPercent")
@onready var gatherRate = get_node("GatherRate")

# Variable to keep track of time since the last resource gathering event
var elapsedTime = 0
var buildingTime = 0
var unitsGathering = []
var unitMask = 0

@export var buildingHealth: int = 1000
@onready var currentHealth: int = buildingHealth

@export_group("Barracks")
@onready var isBarracks : bool = buildingType == "Barracks"
@export var trainingTime : int = 10
var unitsToTrain = {}
var soldierPreload = preload("res://Unit/Soldier.tscn")

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

	var foundation = get_node("Foundation")
	if foundation:
		foundation.visible = false
	constructionProgressLabel.hide()
	updateHealthPercentLabel()
	updateGatherRateLabel()


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
	if !built:
		return

	if isFoundation:
		buildingTime += delta
		var progress = int(min(buildingTime / buildTime, 1.0) * 100)
		constructionProgressLabel.text = str(progress) + "%" + " (" + str(buildTime) + "s)"

		if buildingTime >= buildTime:
			# Allow units to enter again
			var area = get_node("EnterArea")
			if area:
				area.set("scale", Vector2(1, 1))

			built = true
			isFoundation = false
			self_modulate = Color(1, 1, 1, 1)
			var foundation = get_node("Foundation")
			if foundation:
				foundation.visible = false
				constructionProgressLabel.hide()
				updateGatherRateLabel()

	if isFoundation:
		return
			
	elapsedTime += delta
	updateGatherRateLabel()

	if firstloop and buildingType == "House":
		resourceManager.add(ResourceManager.ResourceType.MAXPOP, 5)
		firstloop = false

	if isBarracks:
		HandleBarracks()
		return

	# Check if enough time has passed for resource gathering
	if elapsedTime >= gatherTime:
		elapsedTime = 0  # Reset the timer
		# Calculate the total resource to gather based on amount of units gathering
		var totalResource = gatherAmount * unitsGathering.size()

		if noUnitsRequired:
			totalResource = gatherAmount

		if buildingType == "TownCenter" && resourceManager.check(resource,1):
			# Only add 1 unit
			totalResource = 1

			if unitsGathering.size() >= buildingSize * buildingSize:
				return

			var new_pos = GetNewUnitPosition()

			if new_pos.x == -1 || new_pos.y == -1:
				return

			var unit = loadUnit.instantiate()
			unit.get_node("UnitController").pathingToBuilding = self
			get_node("../../Units").add_child(unit)
			AddUnitToBuilding(unit)
			unit.get_node("StateController").SetState(StateController.State.MOVING)
		
		# Add the resource to the player's inventory
		resourceManager.add(resource, totalResource)


func HandleBarracks():
	for unit in unitsToTrain:
		if unitsToTrain[unit] <= elapsedTime:
			# Unit is done training, add it to the building
			RemoveUnitFromBuilding(unit)
			unit.Destroy()

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
	
	updateGatherRateLabel()


func RemoveUnitFromBuilding(unit):
	# Find new safe position for unit outside of building
	var new_pos = Vector2(0, 0)
	var found = false

	visibleUnits.erase(unit)

	var realBuildingSize = buildingSize
	if overrideBuildingSize != -1:
		realBuildingSize = overrideBuildingSize

	for x in range(-1, realBuildingSize + 2):
		for y in range(-1, realBuildingSize + 2):
			var pos = global_position + Vector2(x, y) * 16 + Vector2(8, 8)
			var tile_pos = grid.WorldToTilePos(pos)
			if grid.TileBlocked(tile_pos):
				continue
			else:
				new_pos = pos
				found = true
				break

		if found:
			break


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

	updateGatherRateLabel()

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
		
		queue_free()
		if buildingType == "House" && !isFoundation && built:
			resourceManager.add(ResourceManager.ResourceType.MAXPOP, -5)

func updateHealthPercentLabel():
	var health_percent = int((currentHealth / float(buildingHealth)) * 100)
	healthPercent.text = "HP: %d/%d (%d%%)" % [currentHealth, buildingHealth, health_percent]

func updateGatherRateLabel():
	if gatherTime > 0:  # To avoid division by zero
		var percentage_time_completed = int((elapsedTime / gatherTime) * 100)
		var totalResourceOnceCompleted = gatherAmount * unitsGathering.size()
		if noUnitsRequired:
			totalResourceOnceCompleted = gatherAmount

		gatherRate.text = "Progress: %d%%, + %d" % [percentage_time_completed, totalResourceOnceCompleted]
	else:
		gatherRate.text = "Gather time is not set."