extends Node

var resourceManager

# Reference to UI elements
@onready var woodLabel = $LabelWood
@onready var goldLabel = $LabelGold
@onready var stoneLabel = $LabelStone
@onready var foodLabel = $LabelFood
@onready var popLabel = $LabelPop

#setting Selection ID Stats
@onready var attackWorker = get_node("../../HUD/HUD/SelectionID/unitPortraitWorker/GridContainer/LabelAttackWorker")
@onready var defenceWorker = get_node("../../HUD/HUD/SelectionID/unitPortraitWorker/GridContainer/LabelDefenceWorker")
@onready var healthWorker = get_node("../../HUD/HUD/SelectionID/unitPortraitWorker/TextureProgressBar/LabelCurrentHealthWorker")
@onready var healthBarWorker = get_node("../../HUD/HUD/SelectionID/unitPortraitWorker/TextureProgressBar")

@onready var attackSolder = get_node("../../HUD/HUD/SelectionID/unitPortraitSolder/GridContainer/LabelAttackSolder")
@onready var defenceSolder = get_node("../../HUD/HUD/SelectionID/unitPortraitSolder/GridContainer/LabelDefenceSolder")
@onready var healthSolder = get_node("../../HUD/HUD/SelectionID/unitPortraitSolder/TextureProgressBar/LabelCurrentHealthSolder")
@onready var healthBarSolder = get_node("../../HUD/HUD/SelectionID/unitPortraitSolder/TextureProgressBar")


var workerHealth = 0
var solderHeatlh = 0

@onready var optionsMenu = get_node("../../OptionsLayer/OptionsMenu")

func _ready():
	# Find and store a reference to the ResourceManager script
	resourceManager = $"../../resourceManager"

	
	attackWorker.text = str(ImportData.unitdata["Worker"]["UnitAttack"])
	defenceWorker.text = str(ImportData.unitdata["Worker"]["UnitArmor"])

	attackSolder.text = str(ImportData.unitdata["Solder"]["UnitAttack"])
	defenceSolder.text = str(ImportData.unitdata["Solder"]["UnitArmor"])




func _process(delta):
	# Update the UI labels with current resource values
	woodLabel.text = str(resourceManager.wood)
	goldLabel.text = str(resourceManager.gold)
	foodLabel.text = str(resourceManager.food)
	stoneLabel.text = str(resourceManager.stone)
	popLabel.text = str(resourceManager.pop) + " / " + str(resourceManager.maxPop)


func _on_texture_button_options_pressed():
	optionsMenu.show()
