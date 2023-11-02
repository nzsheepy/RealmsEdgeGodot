#current buildingManger

extends Node2D
class_name Building

@onready var resourceManager = $"../../resourceManager"
@onready var grid : Grid = $"../../Grid"

@export var buildingSize: int
@export var resource: ResourceManager.ResourceType
@export var gatherAmount: int
@export var gatherTime: int
@export var buildingType : String
@export var noUnitsRequired : bool = false
var loadUnit = preload("res://Unit/unit.tscn")
var firstloop = true
@export var built = false
var isFoundation = false
@export var buildTime : int = 10

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
	var foundation = get_node("Foundation")
	if foundation:
		foundation.visible = false

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


func _process(delta):
	if !built:
		return

	buildingTime += delta
	
	if isFoundation && buildingTime >= buildTime:
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

	if isFoundation:
		return

	elapsedTime += delta
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
			get_node("../../Units").add_child(soldier)

			soldier.get_node("UnitController").canEnterBuildings = true
			AddUnitToBuilding(soldier)
			

func GetNewUnitPosition():
	var unitCount = unitsGathering.size()

	if isBarracks:
		unitCount = unitsToTrain.size()

	if unitCount >= buildingSize * buildingSize:
		return Vector2(-1, -1)

	var tile_pos = Vector2(unitCount % buildingSize, unitCount / buildingSize)

	return global_position + tile_pos * 16 + Vector2(8, 8)


func AddUnitToBuilding(newUnit):
	var unitsCount = unitsGathering.size()

	if isBarracks:
		unitsCount = unitsToTrain.size()

	# Save old unit mask
	unitMask = newUnit.collision_mask

	if unitsCount >= buildingSize * buildingSize:
		return

	var new_pos = GetNewUnitPosition()

	if new_pos.x == -1 || new_pos.y == -1:
		return

	var unitController: UnitController = newUnit.get_node("UnitController")

	if !unitController.CanEnterBuilding():
		return

	if newUnit.has_node("StateController"):
		if isBarracks:
			unitsToTrain[newUnit] = elapsedTime + trainingTime
		else:
			unitsGathering.append(newUnit)

		var stateController: StateController = newUnit.get_node("StateController")
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


func RemoveUnitFromBuilding(unit):
	# Find new safe position for unit outside of building
	var new_pos = Vector2(0, 0)
	var found = false

	for x in range(-1, buildingSize + 2):
		for y in range(-1, buildingSize + 2):
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
		var tile_pos = Vector2(i % buildingSize, i / buildingSize)
		u.position = global_position + tile_pos * 16 + Vector2(8, 8)
		i += 1


func _on_enter_area_body_entered(body:Node2D):
	if body.has_node("StateController"):
		AddUnitToBuilding(body)


func Heal(amount):
	currentHealth += amount
	if currentHealth > buildingHealth:
		currentHealth = buildingHealth


func TakeDamage(damage):
	currentHealth -= damage

	var units = unitsGathering
	if isBarracks:
		units = unitsToTrain

	if currentHealth <= 0:
		for unit in units:
			unit.Destroy()
		
		queue_free()
