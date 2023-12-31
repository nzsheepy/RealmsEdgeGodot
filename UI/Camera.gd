extends Camera2D

var start = Vector2()
var end = Vector2()
var startViewport = Vector2()
var endViewport = Vector2()
var isDragging = false
var edge_threshold = 15
var edge_scroll_speed = 1000
var mouse_scroll_speed = 1
var arrow_key_scroll_speed = 200
var middle_mouse_pressed = false
var last_middle_mouse_position = Vector2()
var zoom_speed = 0.1
var min_zoom = 1  # Minimum zoom level
var max_zoom = 4   # Maximum zoom level
var camera_grip_release_time = -1.0
var edge_pan_cooldown = 0.5  # Time in seconds to disable edge panning after releasing camera grip
var total_elapsed_time = 0.0



@onready var box = get_node("../UI/Panel")
@export var selection: Selection
@export var unitManager: UnitManager

func _process(_delta):
	total_elapsed_time += _delta

	if middle_mouse_pressed:
		handle_camera_grip(_delta)
	else:
		handle_camera_movement(_delta)
		handle_edge_panning(_delta)
	
	#start dragbox location
	if Input.is_action_just_pressed("LeftClick"):
		start = get_global_mouse_position()
		startViewport = get_local_mouse_position()
		isDragging = true
		return

	if isDragging:
		end = get_global_mouse_position()
		endViewport = get_local_mouse_position()
		draw_area()

	#end dragbox location
#end dragbox location
	if Input.is_action_just_released("LeftClick"):
		end = get_global_mouse_position()
		endViewport = get_local_mouse_position()
		var add_to_selection = Input.is_key_pressed(KEY_SHIFT)  # Check if SHIFT is pressed

		var dist = start.distance_to(end)

		if dist > 20:
			isDragging = false
			draw_area(false)
			# use start and end to work out top left and bottom right
			var top_left = Vector2(min(start.x, end.x), min(start.y, end.y))
			var bottom_right = Vector2(max(start.x, end.x), max(start.y, end.y))
			# Now pass the 'add_to_selection' as the third argument
			selection.SelectArea(top_left, bottom_right, add_to_selection)
		elif dist > 0:
			isDragging = false
			draw_area(false)
			# Pass 'add_to_selection' as the second argument
			selection.SelectSingleUnit(get_global_mouse_position(), add_to_selection)
		else:
			end = start
			isDragging = false
			draw_area(false)
			# Pass 'add_to_selection' as the second argument
			selection.SelectSingleUnit(get_global_mouse_position(), add_to_selection)


func handle_camera_grip(_delta):
	var current_mouse_position = get_global_mouse_position()
	var edgeoffset = last_middle_mouse_position - current_mouse_position
	offset_camera(edgeoffset)
	last_middle_mouse_position = get_global_mouse_position()

func handle_camera_movement(_delta):
	var camera_offset = Vector2(0, 0)

	if Input.is_action_pressed("move_camera_left"):
		camera_offset.x -= arrow_key_scroll_speed * _delta
	if Input.is_action_pressed("move_camera_right"):
		camera_offset.x += arrow_key_scroll_speed * _delta
	if Input.is_action_pressed("move_camera_up"):
		camera_offset.y -= arrow_key_scroll_speed * _delta
	if Input.is_action_pressed("move_camera_down"):
		camera_offset.y += arrow_key_scroll_speed * _delta

	if camera_offset.length() > 0:
		camera_offset = camera_offset.normalized() * edge_scroll_speed * _delta
		offset_camera(camera_offset)

func handle_edge_panning(_delta):
	if total_elapsed_time <= camera_grip_release_time + edge_pan_cooldown:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport_rect().size
	var camera_offset = Vector2(0, 0)

	if mouse_pos.x < edge_threshold:
		camera_offset.x = -1
	elif screen_size.x - mouse_pos.x < edge_threshold:
		camera_offset.x = 1

	if mouse_pos.y < edge_threshold:
		camera_offset.y = -1
	elif screen_size.y - mouse_pos.y < edge_threshold:
		camera_offset.y = 1

	if camera_offset.length() > 0:
		camera_offset = camera_offset.normalized() * edge_scroll_speed * _delta
		offset_camera(camera_offset)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and !event.pressed:
			zoom -= Vector2(zoom_speed, zoom_speed)
			zoom.x = clamp(zoom.x, min_zoom, max_zoom)
			zoom.y = clamp(zoom.y, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and !event.pressed:
			zoom += Vector2(zoom_speed, zoom_speed)
			zoom.x = clamp(zoom.x, min_zoom, max_zoom)
			zoom.y = clamp(zoom.y, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				middle_mouse_pressed = true
				last_middle_mouse_position = get_global_mouse_position()
			else:
				middle_mouse_pressed = false
				camera_grip_release_time = total_elapsed_time


func draw_area(s=true):
	box.size = Vector2(abs(startViewport.x - endViewport.x), abs(startViewport.y - endViewport.y))
	var pos = Vector2()
	pos.x = min(startViewport.x, endViewport.x)
	pos.y = min(startViewport.y, endViewport.y)

	box.position = pos + global_position
	box.size *= int(s)

# Function to move the camera
func offset_camera(edgeoffset):
	position += edgeoffset
	position = position.round()

	position.x = clamp(position.x, limit_left, limit_right)
	position.y = clamp(position.y, limit_top, limit_bottom)

	force_update_scroll()

