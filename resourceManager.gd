extends Node2D
#click on resource manager and change in side bar
@export var gold: int 
@export var wood: int 
@export var stone: int 
@export var food: int 
 
enum { GOLD, WOOD, STONE, FOOD }

##Checks cost is greater then current resources
func check(resource, amount):
	if resource == GOLD: 
		return gold>=amount
	if resource == WOOD: 
		return wood>=amount
	if resource == STONE: 
		return stone>=amount
	if resource == FOOD: 
		return food>=amount
		
		
##add resources to current resources
func add(resource, amount):
	if resource == GOLD: 
		gold+=amount
	if resource == WOOD: 
		wood+=amount
	if resource == STONE: 
		stone+=amount
	if resource == FOOD: 
		food+=amount
		
		
##minus cost from current resources
func use(resource, amount):
	if resource == GOLD && check(resource, amount): 
		gold -= amount
		return true
	if resource == WOOD && check(resource, amount): 
		wood -= amount
		return true
	if resource == STONE && check(resource, amount): 
		stone -= amount
		return true
	if resource == FOOD && check(resource, amount): 
		food -= amount
		return true
		
	return false
	

