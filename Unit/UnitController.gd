extends Node2D
class_name UnitController

var selected = false
@onready var box = get_node("../Box")
@onready var stateController = get_node("../StateController")
@onready var grid : Grid = get_node("../../../Grid")
@onready var camera : Camera2D = get_node("../../../Camera")

var occupyingBuilding = null
@export var canEnterBuildings = true
var pathingToBuilding = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_selected(selected)
	

func set_selected(value):
	box.visible = value
	selected = value


func MoveCommand(pos, movingToBuilding):
	if !selected:
		return

	if (occupyingBuilding != null):
		occupyingBuilding.RemoveUnitFromBuilding(get_parent())
		occupyingBuilding = null

	pathingToBuilding = movingToBuilding
	stateController.MoveUnit(pos)


func CanEnterBuilding(building):
	if !pathingToBuilding:
		return false

	if pathingToBuilding != building:
		return false

	if !canEnterBuildings:
		return false

	if occupyingBuilding != null:
		return false

	return true


func SetBuilding(building):
	occupyingBuilding = building
	pathingToBuilding = building


func InBuilding():
	return occupyingBuilding != null