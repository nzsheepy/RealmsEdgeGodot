extends CharacterBody2D
class_name Entity

@export var movement_component: MovementComponent
@export var health_component: HealthComponent

func Destroy():
	# TODO: dereference all references to this object
	queue_free()
