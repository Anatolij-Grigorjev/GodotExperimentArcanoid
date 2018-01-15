extends Node2D

onready var bricks_grid = get_node("bricks_grid")

onready var score = get_node("score")
onready var lives = get_node("lives")

onready var paddle = get_node("paddle")

onready var stage_over_text = get_node("stage_over_text")

var stage_over

func _ready():
	stage_over_text.hide()
	stage_over = false
	
	lives.connect("all_lives_lost", self, "do_no_lives")
	for child in bricks_grid.get_children():
		if (child extends preload("res://brick/brick.gd")):
			child.connect("brick_destroyed", score, "update_score")
			child.connect("brick_destroyed", self, "check_stage_over")
	
	
#check if there are bricks left
func has_bricks_left():

	for child in bricks_grid.get_children():
		if (child extends preload("res://brick/brick.gd")):
			#only count bricks that are still active
			if (not child.brick_dead):
				return true
	
	return false
	
func check_stage_over( brick_val ):
	var bricks = has_bricks_left()
	if (not bricks):
		finish_stage("CONGRATULATIONS!")
	
func do_no_lives():
	var num_balls = get_active_balls_count()
	#its not over until the balls are
	if (num_balls <= 0):
		finish_stage("GAME OVER!")
		
func get_active_balls_count():
	var balls = 0
	for child in get_children():
		if (is_ball(child)):
			#ball only counts as active if its not below the paddle
			if (child.get_pos().y <= paddle.get_pos().y):
				balls += 1
	return balls

func finish_stage(message):
	print(message)
	stage_over_text.set_text(message)
	stage_over_text.show()
	#stop paddle and balls
	paddle.set_process(false)
	for ball in get_children():
		if (is_ball(ball)):
			ball.set_process(false)
	
#resolve situation of ball falling from stage
func ball_fell():
	#anticipate game over and dont spawn ball if it be
	if (not lives.lives_list.empty()):
		paddle.spawn_ball()
	#lose a life
	lives.lost_life()
	
func is_ball(child):
	return child extends preload("res://ball/ball.gd")
	
