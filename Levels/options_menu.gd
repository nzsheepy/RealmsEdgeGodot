extends TextureRect

const target_scene_path = "res://world.tscn"
var loading : bool = false
var resource : PackedScene


func _process(_delta):
	if !loading:
		return

	get_tree().change_scene_to_packed(resource)



func _on_quit_pressed():
	get_tree().quit()


func _on_rtg_pressed():
	hide()


func _on_restart_pressed():
	resource = ResourceLoader.load(target_scene_path)
	loading = true


func _on_arrow_keys_slider_value_changed(value:float):
	pass # Replace with function body.
