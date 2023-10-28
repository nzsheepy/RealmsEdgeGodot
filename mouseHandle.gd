extends Node2D

var mouseBlocked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("LeftClick"):
		print("Left Click, mouse blocked: ", mouseBlocked)


func _on_exit():
	mouseBlocked = false


func _on_entered():
	mouseBlocked = true
	
	

