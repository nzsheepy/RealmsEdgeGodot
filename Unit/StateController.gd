extends Node2D
class_name StateController


enum State {
	IDLE, MOVING, CONSTRUCTING, GATHERING, ATTACKING
}

var state = State.IDLE
@onready var character: Entity = get_parent()

@export_group("Soldier Settings")
@export var isSoldier = false
@export var tryAttack = false
var visibleTargets = []

@export var attackDamage: float = 34.0
@export var attackWaitTime = 1.0
var attackTimer = 0.0

var attackTarget
var moveTargetLoc = null
var enemyTarget

var reacquireTargetWaitTime = 1.5
var reacquireCurrentWaitTime = 1.5
var reacquireTargetDeviation = 0.5
var reacquireTargetTimer = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	reacquireTargetTimer += delta

	if state == State.ATTACKING && isSoldier:
		if !tryAttack:
			return

		character.movement_component.Stop()
		attackTimer += delta

		# if attackTarget == null:
		# 	SetState(State.MOVING)
		# 	reacquireTargetTimer = reacquireTargetWaitTime + 0.1
		# 	return

		if attackTimer > attackWaitTime:
			print("ATTACKING")
			attackTimer = 0.0
			var attackHealthComp = attackTarget.get_node("HealthComponent")
			if attackHealthComp:
				attackHealthComp.TakeDamage(attackDamage)

		return

	if (state == State.MOVING):
		# not moving then set state to idle
		if (!character.movement_component.IsMoving()):
			state = State.IDLE
			moveTargetLoc = null

	if isSoldier && reacquireTargetTimer > reacquireCurrentWaitTime:
		MoveToTarget()
	
	if state == State.IDLE:
		if isSoldier:
			tryAttack = true

	if (state == State.CONSTRUCTING):
		pass

	if (state == State.GATHERING):
		pass

	if (state == State.ATTACKING):
		pass	


func SetState(newState: State):
	state = newState


func MoveUnit(target: Vector2):
	SetState(State.MOVING)
	moveTargetLoc = target
	character.movement_component.SetDestinationWorld(target)


func MoveToTarget():
	if visibleTargets.size() == 0:
		if moveTargetLoc != null:
			MoveUnit(moveTargetLoc)

		SetState(State.IDLE)
		return

	# Find closest visible target
	var newTarget = null
	for visibleTarget in visibleTargets:

		if newTarget == null:
			newTarget = visibleTarget
			continue

		if visibleTarget.global_position.distance_to(character.global_position) <= newTarget.global_position.distance_to(character.global_position):
			newTarget = visibleTarget

	enemyTarget = newTarget

	if enemyTarget == null:
		if moveTargetLoc != null:
			MoveUnit(moveTargetLoc)

		SetState(State.IDLE)
		return

	SetState(State.MOVING)
	MoveUnit(enemyTarget.global_position)
	reacquireTargetTimer = 0.0
	reacquireCurrentWaitTime = reacquireTargetWaitTime + (randf() * reacquireTargetDeviation)


func _on_detection_body_entered(body:Node2D):
	if !body.has_node("EnemyController"):
		return

	visibleTargets.append(body)


func _on_detection_body_exited(body:Node2D):
	if !body.has_node("EnemyController"):
		return

	visibleTargets.erase(body)


func _on_attack_range_body_entered(body:Node2D):
	if !body.has_node("EnemyController"):
		return

	attackTarget = body
	SetState(State.ATTACKING)


func _on_attack_range_body_exited(body:Node2D):
	if !body.has_node("EnemyController"):
		return

	if body != attackTarget:
		return
	
	attackTarget = null

	if moveTargetLoc != null:
		MoveUnit(moveTargetLoc)
	else:
		SetState(State.IDLE)


