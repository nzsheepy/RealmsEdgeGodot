extends Control

const target_scene_path = "res://world.tscn"
var loading : bool = false
var resource : PackedScene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !loading:
		return

	get_tree().change_scene_to_packed(resource)


func _on_start_button_pressed():
	get_node("ControlLoading").show()
	resource = ResourceLoader.load(target_scene_path)
	loading = true

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Levels/main_menu_options.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
