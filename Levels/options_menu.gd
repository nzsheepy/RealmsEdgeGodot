extends TextureRect

#var cameraOptions = get_node
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_pressed():
	get_tree().quit()


func _on_rtg_pressed():
	pass


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://world.tscn")


func _on_arrow_keys_slider_value_changed(value:float):
	pass # Replace with function body.
