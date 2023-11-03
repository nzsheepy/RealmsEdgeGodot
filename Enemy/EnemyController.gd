extends Node2D
class_name EnemyController


enum State {
	MOVING, ATTACKING
}

@onready var buildingPlacement = get_node("../../../buildingPlacement")

var state = State.MOVING
var target
var attackTarget
var townCenterTarget
var necromancer = null
var hasNecromancer = false

var reacquireTargetWaitTime = 1.5
var reacquireCurrentWaitTime = 1.5
var reacquireTargetDeviation = 0.5
var reacquireTargetTimer = 0.0

var visibleTargets = []

@export var attackDamage: float = 25.0
@export var attackWaitTime = 1.0
var attackTimer = 0.0
@onready var character: Entity = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	FindAndMoveTownCenter()

func _physics_process(_delta):
	if hasNecromancer && necromancer == null:
		character.Destroy()
		return

	reacquireTargetTimer += _delta

	if state == State.ATTACKING:
		character.movement_component.Stop()
		attackTimer += _delta

		if attackTarget == null:
			SetState(State.MOVING)
			reacquireTargetTimer = reacquireTargetWaitTime + 0.1
			return

		if attackTimer > attackWaitTime:
			attackTimer = 0.0
			if attackTarget.has_node("HealthComponent"):
				attackTarget.get_node("HealthComponent").TakeDamage(attackDamage)
			else:
				attackTarget.TakeDamage(attackDamage)

		return

	if reacquireTargetTimer > reacquireCurrentWaitTime:
		MoveToTarget()


func SetState(newState: State):
	state = newState


func FindTargetCenter():
	var targetCenter = target.global_position
	if target.has_node("UnitController"):
		return targetCenter

	if target is Building:
		var center = (target.buildingSize / 2.0 * 16)
		return targetCenter + Vector2(center, center)


func FindAndMoveTownCenter():
	if townCenterTarget != null:
		MoveUnit(townCenterTarget.global_position)
		return

	var townCenters = buildingPlacement.GetBuildingsOfType("TownCenter")
	if townCenters.size() == 0:
		character.movement_component.Stop()
		return

	townCenterTarget = townCenters[randi() % townCenters.size()]
	MoveUnit(townCenterTarget.global_position)


func MoveUnit(newTarget: Vector2):
	SetState(State.MOVING)
	character.movement_component.SetDestinationWorld(newTarget)


func MoveToTarget():
	if visibleTargets.size() == 0:
		FindAndMoveTownCenter()
		return

	# Find closest visible target
	var toErase = []
	var newTarget = null
	for visibleTarget in visibleTargets:
		if ValidTarget(visibleTarget) == false:
			toErase.append(visibleTarget)
			continue

		if newTarget == null:
			newTarget = visibleTarget
			continue

		if visibleTarget.global_position.distance_to(character.global_position) <= newTarget.global_position.distance_to(character.global_position):
			newTarget = visibleTarget

	for erase in toErase:
		visibleTargets.erase(erase)

	target = newTarget

	if target == null:
		FindAndMoveTownCenter()
		return

	SetState(State.MOVING)
	character.movement_component.SetDestinationWorld(FindTargetCenter())
	reacquireTargetTimer = 0.0
	reacquireCurrentWaitTime = reacquireTargetWaitTime + (randf() * reacquireTargetDeviation)


func ValidTarget(newTarget):
	if newTarget == null:
		return false

	if newTarget.has_node("UnitController") && newTarget.get_node("UnitController").InBuilding():
		return false

	if newTarget.has_node("UnitController") || newTarget is Building:
		return true

	return false


func _on_detection_body_entered(body: Node2D):
	if ValidTarget(body) == false:
		return

	visibleTargets.append(body)


func _on_detection_body_exited(body):
	if body in visibleTargets:
		visibleTargets.erase(body)


func _on_detection_area_entered(area):
	var body = area.get_parent()

	if ValidTarget(body) == false:
		return

	visibleTargets.append(body)


func _on_detection_area_exited(area):
	var body = area.get_parent()

	if body in visibleTargets:
		visibleTargets.erase(body)


func _on_attack_range_body_entered(body:Node2D):
	if body.has_node("UnitController"):
		attackTarget = body
		SetState(State.ATTACKING)


func _on_attack_range_area_entered(area):
	var body = area.get_parent()

	if body is Building:
		attackTarget = body
		SetState(State.ATTACKING)


func _on_attack_range_body_exited(body:Node2D):
	if body == attackTarget:
		attackTarget = null
		SetState(State.MOVING)
		reacquireTargetTimer = reacquireTargetWaitTime + 0.1
		return


func _on_attack_range_area_exited(area:Area2D):
	var body = area.get_parent()
	if body == attackTarget:
		attackTarget = null
		SetState(State.MOVING)
		reacquireTargetTimer = reacquireTargetWaitTime + 0.1
		return
