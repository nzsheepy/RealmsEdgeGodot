#current buildingManger

extends Node2D

@onready var resourceManager = $"../../resourceManager"

@export var buildingSize: int
@export var resource: ResourceManager.ResourceType
@export var gatherAmount: int
@export var gatherTime: int
@export var buildingType : String
#var whosThere = 
var loadUnit = preload("res://Unit/unit.tscn")
var unit

# Variable to keep track of time since the last resource gathering event
var elapsedTime = 0

func _ready():
	if buildingType == "House":
		# Increase max population by 5 for each house
		resourceManager.add(ResourceManager.ResourceType.MAXPOP, 5)
		print("Added 5 to max population")
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	# Update the elapsed time
	elapsedTime += delta

	# Check if enough time has passed for resource gathering
	if elapsedTime >= gatherTime:
		elapsedTime = 0  # Reset the timer
		# Calculate the total resource to gather based on buildingSize and gatherAmount
		var totalResource = gatherAmount

		if buildingType == "TownCenter" && resourceManager.check(resource,1):
			print("im a towncenter and i should make a unit now")
			#resourceManager.add("Population", 1)
			unit = loadUnit.instantiate()

			get_node("../../Units").add_child(unit)
			unit.global_position = global_position
			resourceManager.add(resource, totalResource)
		
		else:
			print ("resource added", totalResource)
			# Add the resource to the player's inventory
			resourceManager.add(resource, totalResource)


