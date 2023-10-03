extends CharacterBody2D

@export var selected = false
@onready var box = get_node("Box")

@onready var target = position
func _ready():
	set_selected(selected)
	
func set_selected(value):
	box.visible = value
