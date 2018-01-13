extends Node2D

onready var bricks_grid = get_node("bricks_grid")

onready var score = get_node("score")

var stage_over

func _ready():
	
	stage_over = false
		
	for child in bricks_grid.get_children():
		if (child extends preload("res://brick/brick.gd")):
			child.connect("brick_destroyed", score, "update_score")
	
#check if there are bricks left
func has_bricks_left():
	
	for child in bricks_grid.get_children():
		if (child extends preload("res://brick/brick.gd")):
			return true
	
	return false
