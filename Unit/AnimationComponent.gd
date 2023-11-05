extends Node2D

@export var movement_component: MovementComponent
@export var health_component: HealthComponent
@export var isUnit : bool = false
@onready var enemySpanwer = $"../../EnemySpawner"

@onready var resourceManager : ResourceManager = get_node("../../resourceManager")
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var stateController : StateController = $StateController
var character: Entity


# func _process(delta):
# 	update_animation_parameters()

# func update_animation_parameters():
# 	var velocity = movement_component.get_velocity()
# 	if velocity == Vector2.ZERO:
# 		animation_tree["parameters/conditions/idle"] = true
# 		animation_tree["parameters/conditions/is_moving"] = false
# 	else:
# 		animation_tree["parameters/conditions/idle"] = false
# 		animation_tree["parameters/conditions/is_moving"] = true

# func get_velocity() -> Vector2:
# 	return character.velocity

