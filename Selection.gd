extends Node2D
class_name Selection

@export var area: Area2D
@export var collision_shape: CollisionShape2D
@export var unitManager: UnitManager
@export var timer: Timer

var start_drag = Vector2()
var end_drag = Vector2()
var is_dragging = false
var selected = false

func set_selected(value):
	selected = value
	# Additional code to update the unit's appearance or state

func is_selected():
	return selected

func _ready():
	timer.connect("timeout", OnTimeOut)

func SelectArea(topleft: Vector2, botright: Vector2, add_to_selection: bool):
	if not add_to_selection:
		unitManager.DeselectAll()

	area.position = topleft + (botright - topleft) / 2
	var shape: RectangleShape2D = collision_shape.shape
	shape.set("size", Vector2(botright.x - topleft.x, botright.y - topleft.y))
	collision_shape.shape = shape
	timer.start()

func SelectSingleUnit(mousePosition: Vector2, add_to_selection: bool):
	if not add_to_selection:
		unitManager.DeselectAll()

	area.position = mousePosition
	var shape: RectangleShape2D = collision_shape.shape
	shape.set("size", Vector2(1, 1))
	collision_shape.shape = shape
	timer.start()

func OnTimeOut():
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.has_node("UnitController"):
			var unit_controller = body.get_node("UnitController")
			if not unit_controller.is_selected():
				unit_controller.set_selected(true)
	unitManager.unitSelected()

	var shape: RectangleShape2D = collision_shape.shape
	shape.set("size", Vector2(0, 0))
	collision_shape.shape = shape

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var add_to_selection = Input.is_key_pressed(KEY_SHIFT)
			if event.pressed:
				# Start selection
				start_drag = get_global_mouse_position()
				is_dragging = true
			else:
				# End selection
				end_drag = get_global_mouse_position()
				is_dragging = false
				if start_drag.distance_to(end_drag) > 10:  # Threshold for detecting a drag
					# Make sure to pass 'add_to_selection' as the third argument
					SelectArea(start_drag, end_drag, add_to_selection)
				else:
					# Pass 'add_to_selection' as the second argument
					SelectSingleUnit(end_drag, add_to_selection)

