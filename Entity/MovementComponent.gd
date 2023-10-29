extends Node2D
class_name MovementComponent

@export var movement_speed = 50
@export var navAgent: NavigationAgent2D
var grid: Grid
var character: Entity
var current_destination: Vector2 = Vector2(-1, -1)
var current_speed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent()
	# TODO: Add a way to get the grid from the scene
	grid = character.get_parent().get_parent().get_node("Grid")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if (current_speed == 0):
		return

	var currentLocation = character.global_position
	var nextLocation = navAgent.get_next_path_position()
	var newVelocity = (nextLocation - currentLocation).normalized() * current_speed

	navAgent.set_velocity(newVelocity)


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	character.velocity = character.velocity.move_toward(safe_velocity, 100)
	character.move_and_slide()


func _on_navigation_agent_2d_navigation_finished():
	current_speed = 0


func IsMoving():
	return current_speed != 0


func Stop():
	navAgent.target_position = character.global_position
	var velocity = Vector2.ZERO
	navAgent.set_velocity(velocity)


func GetGridPosition():
	return grid.WorldToTilePos(character.global_position)


func SetDestinationGrid(destination: Vector2i):
	current_destination = destination
	character.velocity = Vector2(0.01, 0.01)


func SetDestinationWorld(destination: Vector2i):
	current_destination = grid.WorldToTilePos(destination)
	var world_pos = grid.TileToWorldPos(current_destination)
	# offset by 8 to get the center of the tile
	world_pos += Vector2(8, 8)
	current_speed = movement_speed

	navAgent.target_position = world_pos
