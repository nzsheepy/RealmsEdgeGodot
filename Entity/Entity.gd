extends CharacterBody2D
class_name Entity

@export var movement_component: MovementComponent
@export var health_component: HealthComponent
@export var isUnit : bool = false
@onready var enemySpanwer = $"../../EnemySpawner"

@onready var resourceManager : ResourceManager = get_node("../../resourceManager")
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var stateController : StateController = $StateController

# func getCurrentHealth():
# 	return health_component.current_health

func Destroy(killed = true):
	if isUnit:
		resourceManager.use(resourceManager.ResourceType.POP, 1)

		if killed:
			enemySpanwer.spawnEnemy(global_position)

	queue_free()
