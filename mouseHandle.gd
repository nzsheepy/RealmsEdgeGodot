extends Node2D

var mouseBlocked = false
@onready var labelBuildingName = $"../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/LabelBuildingName"
@onready var labelBuildingdescription = $"../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/LabelBuildingDescription"

@onready var mouseClick = $"../CursorClick"

var elapsedTime = 0  # Initialize elapsedTime to 0

# Called when the node enters the scene tree for the first time.
func _ready():
	mouseClick.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("LeftClick"):
		print("Left Click, mouse blocked: ", mouseBlocked)
	
	if Input.is_action_just_pressed("RightClick") and not mouseBlocked:
		mouseClick.position = get_global_mouse_position()
		mouseClick.show()
		# Assuming 'animation_player' is the AnimationPlayer node that controls the animation
		var animation_player = mouseClick.get_node("../CursorClick/Sprite2D/AnimationPlayer")  # Replace with your actual AnimationPlayer path
		animation_player.stop()  # Stop any current animation
		animation_player.play("click")  # Replace with your actual animation name
		elapsedTime = 0

	elapsedTime += delta
	if elapsedTime > 0.2:
		mouseClick.hide()
		elapsedTime = 0



func show_button_tips():
	get_node("../HUD/HUD/CommandCardBuildingTips").visible = true


func hide_button_tips():
	get_node("../HUD/HUD/CommandCardBuildingTips").visible = false

func hide_resource_tips():
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_gold").hide()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_wood").hide()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_stone").hide()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_food").hide()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/TextureGold").hide()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/TextureWood").hide()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/TextureStone").hide()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/TextureFood").hide()

func show_resource_tips():
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_gold").show()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_wood").show()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_stone").show()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/Label_food").show()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/TextureGold").show()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/TextureWood").show()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/TextureStone").show()
	get_node("../HUD/HUD/CommandCardBuildingTips/PanelContainerBuildingTips/VBoxContainer/HBoxContainer/TextureFood").show()
	
func _on_exit():
	mouseBlocked = false


func _on_entered():
	mouseBlocked = true
	
	
func _on_build_menu_button_mouse_entered():
	show_button_tips()
	hide_resource_tips()
	labelBuildingName.text = "Build Menu"
	labelBuildingdescription.text = "Click to open the build menu"

func _on_build_menu_button_mouse_exited():
	hide_button_tips()
	show_resource_tips()

func _on_unit_stop_button_mouse_exited():
	hide_button_tips()
	show_resource_tips()


func _on_unit_stop_button_mouse_entered():
	show_button_tips()
	hide_resource_tips()
	labelBuildingName.text = "Stop Command (hotkey: S)"
	labelBuildingdescription.text = "Click to command the selected units to stop"


func _on_unit_move_button_mouse_exited():
	hide_button_tips()
	show_resource_tips()


func _on_unit_move_button_mouse_entered():
	show_button_tips()
	hide_resource_tips()
	labelBuildingName.text = "Move Command (hotkey: M)"
	labelBuildingdescription.text = "Click to command the selected units to move to a location"


func _on_unit_attack_button_mouse_exited():
	hide_button_tips()
	show_resource_tips()

func _on_unit_attack_button_mouse_entered():
	show_button_tips()
	hide_resource_tips()
	labelBuildingName.text = "Attack Move (hotkey: A)"
	labelBuildingdescription.text = "Click to command the selected units to attack move to a location"
