extends Control

var first = true

func _init():
	visible = true


func _process(_delta):
	if first:
		visible = false
		first = false
