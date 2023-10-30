extends Node2D
class_name HealthComponent

@export var health: int = 100
var current_health: int = health
var character: Entity

func _ready():
	character = get_parent()


func Heal(amount: int):
	current_health = min(current_health + amount, health)


func TakeDamage(amount: int):
	current_health = max(current_health - amount, 0)

	if (current_health == 0):
		character.Destroy()
