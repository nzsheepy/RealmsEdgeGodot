extends Node2D
class_name StateController


enum State {
	IDLE, MOVING, CONSTRUCTING, GATHERING, ATTACKING
}

var state = State.IDLE
@onready var character: Entity = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (state != State.MOVING):
		character.movement_component.Stop()

	if (state == State.MOVING):
		# not moving then set state to idle
		if (!character.movement_component.IsMoving()):
			state = State.IDLE
	
	if (state == State.CONSTRUCTING):
		pass

	if (state == State.GATHERING):
		pass

	if (state == State.ATTACKING):
		pass	


func SetState(newState: State):
	state = newState


func MoveUnit(target: Vector2):
	character.movement_component.SetDestinationWorld(target)
	state = State.MOVING
