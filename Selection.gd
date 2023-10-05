extends Node2D
class_name Selection

@export var area: Area2D
@export var collision_shape: CollisionShape2D
@export var unitManager: UnitManager
@export var timer: Timer

func SelectArea(topleft: Vector2, botright: Vector2):
	area.position = topleft + (botright - topleft) / 2

	var shape: RectangleShape2D = collision_shape.shape
	shape.set("size", Vector2(botright.x - topleft.x, botright.y - topleft.y))
	collision_shape.shape = shape

	unitManager.DeselectAll()

	timer.connect("timeout", OnTimeOut)
	timer.start()


func OnTimeOut():
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.has_node("UnitController"):
			body.get_node("UnitController").set_selected(true)
