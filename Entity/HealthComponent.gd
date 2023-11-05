extends Node2D
class_name HealthComponent

@export var health: int = 100
@onready var current_health: int = health
var character: Entity


#billy please link these you have access to:
#UnitAttack	UnitAttackWait	UnitArmor	UnitHealth	UnitGoldCost	UnitWoodCost	UnitStoneCost	UnitFoodCost	unitSpeed
var unit_data_worker = ImportData.unitdata["Worker"]
var unit_data_solder = ImportData.unitdata["Solder"]
var unit_data_Zombie = ImportData.unitdata["Zombie"]

@onready var healthPercentLabel = get_node("../healthPercent")
@onready var healthBar = get_node("../TexturehealthBar")

func _ready():
	character = get_parent()
	updateHealthPercentLabel()
func Heal(amount: int):
	current_health = min(current_health + amount, health)


func TakeDamage(amount: int):
	if character.isUnit && character.get_node("UnitController").InBuilding():
		return

	current_health = max(current_health - amount, 0)
	updateHealthPercentLabel()

	if (current_health == 0):
		character.Destroy()


func updateHealthPercentLabel():
	var health_percent = int((current_health / float(health)) * 100)
	healthBar.value = health_percent  # Update the health bar's value

	# Update the label's text to show the current health
	healthPercentLabel.text = "HP: %d/%d (%d%%)" % [current_health, health, health_percent]

	# Decide whether to show or hide the health bar and label based on the health percentage
	if health_percent < 90:
		healthBar.show()
		healthPercentLabel.show()
	else:
		healthBar.hide()
		healthPercentLabel.hide()
