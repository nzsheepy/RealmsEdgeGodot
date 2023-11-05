extends TextureRect

# Assuming UIGlobal is the name of your autoloaded script
# and it has the functions set_arrow_key_scroll_speed, set_edge_scroll_speed, and set_camera_grip_release_time

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_quit_button_pressed():
	get_tree().quit()

func _on_arrow_keys_slider_value_changed(value:float):
	print("options arrowkeyvalue: ", value)
	UIGlobal.set_arrow_key_scroll_speed(value)

func _on_edge_pan_slider_value_changed(value:float):
	print("options edge pan value: ", value)
	UIGlobal.set_edge_scroll_speed(value)

func _on_camera_grip_slider_value_changed(value:float):
	print("options camera grip value: ", value)
	UIGlobal.set_camera_grip_release_time(value)

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Levels/menu.tscn")


func _on_difficulty_slider_value_changed(value: int):
	print("Difficulty slider value changed to:", value)
	UIGlobal.set_difficulty_level(value)

