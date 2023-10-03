extends CharacterBody2D
class_name Entity


func Destroy():
	# TODO: dereference all references to this object
	queue_free()
