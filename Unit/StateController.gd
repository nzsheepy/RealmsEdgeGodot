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

	if state == State.ATTACKING && tryAttack:
		if get_node("../UnitController").InBuilding():
			return

		character.movement_component.Stop()
		attackTimer += delta

		if attackTimer > attackWaitTime:
			attackTimer = 0.0
			if attackTarget == null:
				SetState(State.IDLE)
				return

			var attackHealthComp = attackTarget.get_node("HealthComponent")
			if attackHealthComp:
				attackHealthComp.TakeDamage(attackDamage)
			elif attackTarget.get_node("Attackable"):
				var attackable = attackTarget.get_node("Attackable")
				if attackable:
					attackable.TakeDamage(attackDamage)

		return

	if (state == State.MOVING):
		# not moving then set state to idle
		if (!character.movement_component.IsMoving()):
			state = State.IDLE
			moveTargetLoc = null

	if tryAttack && reacquireTargetTimer > reacquireCurrentWaitTime:
		MoveToTarget()
	
	if state == State.IDLE:
		tryAttack = true

	if (state == State.CONSTRUCTING):
		pass

	if (state == State.GATHERING):
		pass

	if (state == State.ATTACKING):
		pass	


func SetState(newState: State):
	state = newState


func SetAgression(agressive: bool):
	tryAttack = agressive


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


func _on_detection_area_entered(area:Area2D):
	var parent = area.get_parent()
	var attackable = parent.get_node("Attackable")
	if !attackable:
		return

	visibleTargets.append(parent)


func _on_detection_area_exited(area:Area2D):
	var parent = area.get_parent()
	var attackable = parent.get_node("Attackable")
	if !attackable:
		return

	visibleTargets.erase(parent)


func _on_attack_range_area_entered(area:Area2D):
	var parent = area.get_parent()
	var attackable = parent.get_node("Attackable")
	if !attackable:
		return

	attackTarget = parent
	SetState(State.ATTACKING)


func _on_attack_range_area_exited(area:Area2D):
	var parent = area.get_parent()
	var attackable = parent.get_node("Attackable")
	if !attackable:
		return

	if parent != attackTarget:
		return

	attackTarget = null

	if moveTargetLoc != null:
		MoveUnit(moveTargetLoc)
	else:
		SetState(State.IDLE)
