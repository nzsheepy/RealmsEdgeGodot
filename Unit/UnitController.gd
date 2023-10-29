extends Node2D
class_name UnitController

var selected = false
@onready var box = get_node("../Box")
@onready var stateController = get_node("../StateController")
@onready var grid : Grid = get_node("../../../Grid")
@onready var camera : Camera2D = get_node("../../../Camera")

var occupyingBuilding = null
var enterBuildingCooldown = 1.5
var enterBuildingTimer = enterBuildingCooldown + 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
	set_selected(selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	enterBuildingTimer += delta
	
	if (!selected):
		return

	if (Input.is_action_just_released("RightClick")):
		if (occupyingBuilding != null):
			occupyingBuilding.RemoveUnitFromBuilding(get_parent())
			enterBuildingTimer = 0.0
			occupyingBuilding = null

		stateController.MoveUnit(get_global_mouse_position())
	

func set_selected(value):
	box.visible = value
	selected = value


func CanEnterBuilding():
	if (enterBuildingTimer < enterBuildingCooldown):
		return false

	return true


func SetBuilding(building):
	occupyingBuilding = building
