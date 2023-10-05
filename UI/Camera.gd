extends Camera2D

var start = Vector2()
var startV = Vector2()
var end = Vector2()
var endV = Vector2()
var isDragging = false

@onready var box = get_node("../UI/Panel")
@export var selection: Selection
@export var unitManager: UnitManager

func _process(_delta):
	if Input.is_action_just_pressed("LeftClick"):
		start = get_global_mouse_position()
		startV = start * 2
		isDragging = true
		return
	
	if isDragging:
		end = get_global_mouse_position()
		endV = end * 2
		draw_area()
	
	
	if Input.is_action_just_released("LeftClick"):
		end = get_global_mouse_position()
		endV = end * 2

		var dist = startV.distance_to(endV)

		if dist > 20:
			isDragging = false
			draw_area(false)
			# use start and end to work out top left and bottom right
			var top_left = Vector2()
			var bottom_right = Vector2()
			top_left.x = min(start.x, end.x)
			top_left.y = min(start.y, end.y)
			bottom_right.x = max(start.x, end.x)
			bottom_right.y = max(start.y, end.y)
			selection.SelectArea(top_left, bottom_right)
		elif dist > 0:
			isDragging = false
			draw_area(false)
			unitManager.DeselectAll()
		else:
			end = start
			isDragging = false
			draw_area(false)


func draw_area(s=true):
	box.size = Vector2(abs(startV.x - endV.x), abs(startV.y - endV.y))
	var pos = Vector2()
	pos.x = min(startV.x, endV.x)
	pos.y = min(startV.y, endV.y)
	box.position = pos
	box.size *= int(s)
