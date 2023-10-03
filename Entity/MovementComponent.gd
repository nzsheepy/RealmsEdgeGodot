extends Node2D
class_name MovementComponent

@export var movement_speed = 100
@export var grid: Grid
var character: Entity
var current_destination: Vector2 = Vector2(-1, -1)

# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent()
	# TODO: Add a way to get the grid from the scene
	grid = character.get_parent().get_parent().get_node("Grid")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var world_position = grid.TileToWorldPos(current_destination)
	var distance = character.global_position.distance_to(world_position)
	var velocity = (world_position - character.global_position).normalized() * movement_speed

	if (distance < 5):
		velocity = Vector2.ZERO
	
	character.velocity = velocity
	character.move_and_slide()


func GetGridPosition():
	return grid.WorldToTilePos(character.global_position)


func SetDestination(destination: Vector2):
	current_destination = destination

