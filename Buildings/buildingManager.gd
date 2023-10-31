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


func startBuild():
	# Prevent units from entering the building
	var area :Area2D = get_node("EnterArea")
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


func GetNewUnitPosition():
	if unitsGathering.size() >= buildingSize * buildingSize:
		return Vector2(-1, -1)

	var tile_pos = Vector2(unitsGathering.size() % buildingSize, unitsGathering.size() / buildingSize)

	return global_position + tile_pos * 16 + Vector2(8, 8)


func AddUnitToBuilding(newUnit):
	# Save old unit mask
	unitMask = newUnit.collision_mask

	if unitsGathering.size() >= buildingSize * buildingSize:
		return

	var new_pos = GetNewUnitPosition()

	if new_pos.x == -1 || new_pos.y == -1:
		return

	var unitController: UnitController = newUnit.get_node("UnitController")

	if !unitController.CanEnterBuilding():
		return

	if newUnit.has_node("StateController"):
		unitsGathering.append(newUnit)

		var stateController: StateController = newUnit.get_node("StateController")
		stateController.SetState(StateController.State.GATHERING)

		unitController.set_selected(false)
		unitController.SetBuilding(self)

		# Disable layermasks
		newUnit.collision_mask = 0

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

	unitsGathering.erase(unit)
	unit.collision_mask = unitMask

	var stateController: StateController = unit.get_node("StateController")
	stateController.SetState(StateController.State.MOVING)

	# Enable NavAgent
	var navAgent : NavigationAgent2D = unit.get_node("NavigationAgent2D")
	navAgent.avoidance_enabled = true

	# Reset position of current units
	for i in range(unitsGathering.size()):
		var tile_pos = Vector2(i % buildingSize, i / buildingSize)
		unitsGathering[i].position = global_position + tile_pos * 16 + Vector2(8, 8)


func _on_enter_area_body_entered(body:Node2D):
	if body.has_node("StateController"):
		AddUnitToBuilding(body)


func Heal(amount):
	currentHealth += amount
	if currentHealth > buildingHealth:
		currentHealth = buildingHealth


func TakeDamage(damage):
	currentHealth -= damage
	if currentHealth <= 0:
		for unit in unitsGathering:
			unit.Destroy()
		
		queue_free()
