# ui_global.gd
extends Node


var difficulty_level = 1  # Default difficulty level (1: Easy, 2: Medium, 3: Hard)
@onready var resourceManager = $"../resourceManager"
@onready var camera_node = $"../Camera"

func _ready():
	pass

func set_arrow_key_scroll_speed(value: float) -> void:
	if camera_node:
		camera_node.arrow_key_scroll_speed = value
		print("new arrow key speed:", value)
	else:
		_print_scene_tree()

func set_edge_scroll_speed(value: float) -> void:
	if camera_node:
		camera_node.edge_scroll_speed = value
		print("new edge scroll speed:", value)
	else:
		_print_scene_tree()

func set_camera_grip_release_time(value: float) -> void:
	if camera_node:
		camera_node.camera_grip_release_time = value
		print("new camera grip release time:", value)
	else:
		_print_scene_tree()

func _print_scene_tree() -> void:
	print("Camera node not found")
	print("Current scene tree:")
	print(get_tree().get_root().get_children())

func set_difficulty_level(value: int) -> void:
	difficulty_level = value
	print("Global Difficulty level set to:", difficulty_level)
	var resourceModifer = difficulty_level*0.90
	#changes starting resources based on difficulty level
	resourceManager.gold = resourceModifer
	resourceManager.wood = resourceModifer
	resourceManager.stone = resourceModifer
	resourceManager.food = resourceModifer
	# Here you can add additional logic to adjust game variables based on difficulty

