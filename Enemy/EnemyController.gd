extends Node2D
class_name EnemyController


enum State {
	MOVING, ATTACKING
}


var state = State.MOVING
var target : Entity
var attackTarget : Entity

var reacquireTargetWaitTime = 1.5
var reacquireTargetDeviation = 0.5
var reacquireTargetTimer = 0.0

@export var attackDamage: float = 30.0
@export var attackWaitTime = 1.0
var attackTimer = 0.0
@onready var character: Entity = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	MoveUnit(Vector2(230, 200))


func _physics_process(_delta):
	reacquireTargetTimer += _delta
	
	if target == null:
		return

	if state == State.ATTACKING:
		attackTimer += _delta

		if attackTimer > attackWaitTime:
			attackTimer = 0.0
			attackTarget.get_node("HealthComponent").TakeDamage(attackDamage)

		return

	if reacquireTargetTimer > reacquireTargetWaitTime:
		MoveToTarget()


func SetState(newState: State):
	state = newState


func MoveUnit(newTarget: Vector2):
	SetState(State.MOVING)
	character.movement_component.SetDestinationWorld(newTarget)


func MoveToTarget():
	if target == null:
		return

	SetState(State.MOVING)
	character.movement_component.SetDestinationWorld(target.global_position)
	reacquireTargetTimer = 0.0
	reacquireTargetWaitTime = reacquireTargetWaitTime + (randf() * reacquireTargetDeviation)


func _on_detection_body_entered(body: Node2D):
	if body.has_node("UnitController"):
		if target != null:
			if body.global_position.distance_to(character.global_position) < target.global_position.distance_to(character.global_position):
				return
		
		SetState(State.ATTACKING)
		target = body
		MoveToTarget()


func _on_detection_body_exited(body):
	if body == target:
		target = null
		MoveUnit(Vector2(230, 200))


func _on_attack_range_body_entered(body:Node2D):
	if body.has_node("UnitController"):
		attackTarget = body
		SetState(State.ATTACKING)
	