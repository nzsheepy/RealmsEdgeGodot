extends Node2D
class_name ResourceManager

#click on resource manager and change in side bar
@export var gold: int 
@export var wood: int 
@export var stone: int 
@export var food: int 
@export var pop: int 
@export var maxPop: int

 
enum ResourceType { GOLD, WOOD, STONE, FOOD, POP, MAXPOP }

##Checks cost is greater then current resources
func check(resource, amount):
	if resource == ResourceType.GOLD: 
		return gold>=amount
	if resource == ResourceType.WOOD: 
		return wood>=amount
	if resource == ResourceType.STONE: 
		return stone>=amount
	if resource == ResourceType.FOOD: 
		return food>=amount
	if resource == ResourceType.POP: 
		return maxPop>pop
		
		
##add resources to current resources
func add(resource, amount):
	if resource == ResourceType.GOLD: 
		gold+=amount
	if resource == ResourceType.WOOD: 
		wood+=amount
	if resource == ResourceType.STONE: 
		stone+=amount
	if resource == ResourceType.FOOD: 
		food+=amount
	if resource == ResourceType.POP && check(resource, amount): 
		pop+=amount
	if resource == ResourceType.MAXPOP:
		maxPop+=amount
		print("maxPop",maxPop)
		
		
##minus cost from current resources
func use(resource, amount):
	if resource == ResourceType.GOLD && check(resource, amount): 
		gold -= amount
		return true
	if resource == ResourceType.WOOD && check(resource, amount): 
		wood -= amount
		return true
	if resource == ResourceType.STONE && check(resource, amount): 
		stone -= amount
		return true
	if resource == ResourceType.FOOD && check(resource, amount): 
		food -= amount
		return true
	if resource == ResourceType.POP:
		pop-=amount
		return true
	if resource == ResourceType.MAXPOP:
		maxPop-=amount
		return true
		
	print("not enough",resource)
	return false


	
	

