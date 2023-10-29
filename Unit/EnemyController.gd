extends Node2D
class_name EnemyController


enum State {
	MOVING, ATTACKING
}


var state = State.MOVING
@onready var character: Entity = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	MoveUnit(Vector2(250, 250))


func SetState(newState: State):
	state = newState


func MoveUnit(target: Vector2):
	SetState(State.MOVING)
	character.movement_component.SetDestinationWorld(target)