extends Node2D
class_name EnemyController


enum State {
	MOVING, ATTACKING
}


var state = State.MOVING
var target
var attackTarget

var reacquireTargetWaitTime = 1.5
var reacquireTargetDeviation = 0.5
var reacquireTargetTimer = 0.0

@export var attackDamage: float = 25.0
@export var attackWaitTime = 1.0
var attackTimer = 0.0
@onready var character: Entity = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	FindAndMoveTownCenter()


func _physics_process(_delta):
	reacquireTargetTimer += _delta
	
	if target == null:
		return

	if ValidTarget(target) == false:
		target = null
		FindAndMoveTownCenter()
		return

	if state == State.ATTACKING:
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

	if reacquireTargetTimer > reacquireTargetWaitTime:
		MoveToTarget()


func SetState(newState: State):
	state = newState


func FindAndMoveTownCenter():
	# TODO: Find town center
	# var townCenter = Vector2(230, 200)
	# if townCenter == null:
	# 	return

	MoveUnit(Vector2(230, 200))


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


func ValidTarget(newTarget):
	if newTarget == null:
		return false

	if newTarget.has_node("UnitController") && newTarget.get_node("UnitController").InBuilding():
		return false

	return true


func _on_detection_body_entered(body: Node2D):
	if target != null:
		if target.global_position.distance_to(character.global_position) < body.global_position.distance_to(character.global_position):
			return

	if ValidTarget(body) == false:
		return

	if body.has_node("UnitController"):
		target = body
		MoveToTarget()
		return


func _on_detection_body_exited(body):
	if body == target:
		target = null
		FindAndMoveTownCenter()


func _on_attack_range_body_entered(body:Node2D):
	if body.has_node("UnitController"):
		attackTarget = body
		SetState(State.ATTACKING)
	


func _on_detection_area_entered(area):
	var body = area.get_parent()

	if target != null:
		if target.global_position.distance_to(character.global_position) < body.global_position.distance_to(character.global_position):
			return

	if body.has_method("IsBuilding") && body.IsBuilding():
		SetState(State.ATTACKING)
		target = body
		MoveToTarget()
		return


func _on_detection_area_exited(area):
	var body = area.get_parent()
	if body == target:
		target = null
		FindAndMoveTownCenter()


func _on_attack_range_area_entered(area):
	var body = area.get_parent()

	if body.has_method("IsBuilding") && body.IsBuilding():
		attackTarget = body
		SetState(State.ATTACKING)
