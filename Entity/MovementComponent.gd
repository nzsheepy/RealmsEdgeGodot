extends Node2D
class_name MovementComponent

@export var movement_speed = 50
@export var grid: Grid
var character: Entity
var current_destination: Vector2 = Vector2(-1, -1)

# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent()
	# TODO: Add a way to get the grid from the scene
	grid = character.get_parent().get_parent().get_node("Grid")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (current_destination == Vector2(-1, -1)):
		return
	
	var world_position = grid.TileToWorldPos(current_destination)
	var distance = character.global_position.distance_to(world_position)
	var velocity = (world_position - character.global_position).normalized() * movement_speed

	if (distance < 2):
		velocity = Vector2.ZERO
	
	character.velocity = velocity
	# TODO: Compare with move_and_slide (Don't want anything sliding)
	character.move_and_collide(velocity * delta)


func IsMoving():
	return character.velocity != Vector2.ZERO


func Stop():
	if (current_destination == Vector2(-1, -1)):
		return

	current_destination = Vector2(-1, -1)
	var velocity = Vector2.ZERO
	character.velocity = velocity
	character.move_and_collide(velocity)


func GetGridPosition():
	return grid.WorldToTilePos(character.global_position)


func SetDestinationGrid(destination: Vector2i):
	current_destination = destination
	character.velocity = Vector2(0.01, 0.01)


func SetDestinationWorld(destination: Vector2i):
	current_destination = grid.WorldToTilePos(destination)
	character.velocity = Vector2(0.01, 0.01)
