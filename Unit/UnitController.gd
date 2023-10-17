extends Node2D
class_name UnitController

var selected = false
@onready var box = get_node("../Box")
@onready var stateController = get_node("../StateController")


# Called when the node enters the scene tree for the first time.
func _ready():
	set_selected(selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (!selected):
		return

	if (Input.is_action_just_released("RightClick")):
		stateController.MoveUnit(get_global_mouse_position())
	

func set_selected(value):
	box.visible = value
	selected = value
