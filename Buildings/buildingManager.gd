extends Node

@onready var resourceManager = $"../../resourceManager"
@export var buildingSize: int
@export var resource: ResourceManager.ResourceType
@export var gatherAmount: int
@export var gatherTime: int



# Variable to keep track of time since the last resource gathering event
var elapsedTime = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update the elapsed time
	elapsedTime += delta

	# Check if enough time has passed for resource gathering
	if elapsedTime >= gatherTime:
		elapsedTime = 0  # Reset the timer

		# Calculate the total resource to gather based on buildingSize and gatherAmount
		var totalResource = buildingSize * gatherAmount
		print ("resource added", totalResource)
		# Add the resource to the player's inventory
		resourceManager.add(resource, totalResource)
