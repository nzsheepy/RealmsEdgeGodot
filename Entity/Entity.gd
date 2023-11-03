extends CharacterBody2D
class_name Entity

@export var movement_component: MovementComponent
@export var health_component: HealthComponent
@export var isUnit : bool = false
@onready var enemySpanwer = $"../../EnemySpawner"

@onready var resourceManager : ResourceManager = get_node("../../resourceManager")

func Destroy():
	# TODO: dereference all references to this object
	enemySpanwer.spawnEnemy(global_position)
	queue_free()

	if isUnit:
		resourceManager.use(resourceManager.ResourceType.POP, 1)
