extends Node2D

onready var bricks_grid = get_node("bricks_grid")

var stage_over

func _ready():
	
	stage_over = false
		
	for child in bricks_grid.get_children():
		if (child extends preload("res://brick/brick.gd")):
			child.connect("brick_destroyed", self, "check_stage_over")
	
#check if there are bricks left
func has_bricks_left():
	
	for child in bricks_grid.get_children():
		if (child extends preload("res://brick/brick.gd")):
			return true
	
	return false
	
func check_stage_over():
	stage_over = not has_bricks_left()
	if (stage_over):
		print("stage finished!")
		#TODO: finish stage
		pass
