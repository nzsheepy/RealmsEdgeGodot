extends Node2D

@export var maxHealth = 500
@onready var health = maxHealth


func TakeDamage(damage):
	health -= damage
	if health <= 0:
		get_parent().queue_free()

