extends Node

var resourceManager

# Reference to UI elements
@onready var woodLabel = $LabelWood
@onready var goldLabel = $LabelGold
@onready var stoneLabel = $LabelStone
@onready var foodLabel = $LabelFood

func _ready():
	# Find and store a reference to the ResourceManager script
	resourceManager = $"../../resourceManager"
	
func _process(delta):
	# Update the UI labels with current resource values
	woodLabel.text = str(resourceManager.wood)
	goldLabel.text = str(resourceManager.gold)
	foodLabel.text = str(resourceManager.food)
	stoneLabel.text = str(resourceManager.stone)
