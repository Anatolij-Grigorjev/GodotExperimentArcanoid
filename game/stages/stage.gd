extends Node2D

onready var bricks_grid = get_node("bricks_grid")

onready var score = get_node("score")
onready var lives = get_node("lives")

onready var paddle = get_node("paddle")

var stage_over

func _ready():
	
	stage_over = false
	
	lives.connect("all_lives_lost", self, "do_game_over")
	for child in bricks_grid.get_children():
		if (child extends preload("res://brick/brick.gd")):
			child.connect("brick_destroyed", score, "update_score")
			child.connect("brick_destroyed", self, "check_stage_over")
	
#check if there are bricks left
func has_bricks_left():
	
	for child in bricks_grid.get_children():
		if (child extends preload("res://brick/brick.gd")):
			return true
	
	return false
	
func check_stage_over( brick_val ):
	var bricks = has_bricks_left()
	if (not bricks):
		print("Stage Over!")
	
func do_game_over():
	print("Game Over!")
	
#resolve situation of ball falling from stage
func ball_fell():
	#anticipate game over and dont spawn ball if it be
	if (not lives.lives_list.empty()):
		paddle.spawn_ball()
	#lose a life
	lives.lost_life()
	
