extends Node2D

@export var maxHealth = 500
@export var isNecromancer = false
@onready var health = maxHealth


func TakeDamage(damage):
	health -= damage
	if health <= 0:
		if isNecromancer:
			var gameState = get_node("../../../GameStateTracker")
			if gameState:
				gameState.RemoveNecromancer()
		
		get_parent().queue_free()

