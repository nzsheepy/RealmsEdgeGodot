extends Node

var buildingdata
var unitdata

func _ready():
	var buildingdata_file = FileAccess.open("res://Data/buildingDataSpreadSheet.json", FileAccess.READ)
	buildingdata = JSON.parse_string(buildingdata_file.get_as_text())
	buildingdata_file.close()
	#print (buildingdata["TownCenter"]["BuildingHealth"])
	var unitdata_file = FileAccess.open("res://Data/unitDataSpreadSheet.json", FileAccess.READ)
	unitdata = JSON.parse_string(unitdata_file.get_as_text())
	unitdata_file.close()
	#print (unitdata["Worker"]["UnitHealth"])
