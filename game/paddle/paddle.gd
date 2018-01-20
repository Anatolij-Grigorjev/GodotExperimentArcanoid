extends KinematicBody2D

onready var G = get_node("/root/game_state")

#max paddle move speed, limited by mouse as well
var max_move_speed 

onready var ball_spawn_pos = get_node("ball_spawn_pos")
onready var paddle_top_pos = get_node("paddle_top_pos")
onready var under_paddle_pos = get_node("under_paddle_pos")

var ball_scene = preload("res://ball/ball.tscn")

var prev_spawn_ball_pressed = false

#vector of movement bounds, screen size X minus sprite extents
var move_bounds

var paddle_rect

func _ready():

	move_bounds = Vector2(0, get_viewport_rect().size.x)
	
	#obtain speed as a function of 
	#total disctance to cross in 1 second(-s)
	max_move_speed = move_bounds.y * 1.5
	
	var extents = G.get_sprite_extents( get_node("sprite") )
	paddle_rect = Rect2(get_pos(), extents * 2)
	
	#correct movement bounds
	move_bounds.x += extents.x
	move_bounds.y -= extents.x
	
	spawn_ball()
	
	set_process(true)
	
func _process(delta):
	var mouse_pos = get_global_mouse_pos()
		
	var new_pos = get_pos()
	var mouse_speed = Input.get_mouse_speed()
	
	#adjust speed for overshooting mouse
	var global = get_global_pos()
	if (global.x < mouse_pos.x and mouse_speed.x < 0):
		mouse_speed = Vector2(0, 0)
	if (global.x > mouse_pos.x and mouse_speed.x > 0):
		mouse_speed = Vector2(0, 0)
	
	#integrate new position
	new_pos.x += clamp(mouse_speed.x, -max_move_speed, max_move_speed) * delta
	
	#clamp to screen size
	new_pos.x = clamp(new_pos.x, move_bounds.x, move_bounds.y)
	
	set_pos(new_pos)
	
	paddle_rect.pos = new_pos
	
	var spawn_ball_pressed = Input.is_action_pressed("spawn_ball")
	#if action released this frame
	if (not spawn_ball_pressed and prev_spawn_ball_pressed):
		spawn_ball()
	
	var launch_ball_pressed = Input.is_action_pressed("launch_ball")
	if (launch_ball_pressed):
		#if action pressed and we have a ball to launch
		var child_ball = get_child_ball()
		if (child_ball != null):
			launch_ball( child_ball )
	
	prev_spawn_ball_pressed = spawn_ball_pressed

#fetch the first found direct child who is a ball
func get_child_ball():
	for child in get_children():
		if (child extends preload("res://ball/ball.gd")):
			return child
	return null
	
func launch_ball( ball ):
	var ball_pos = ball.get_global_pos()
	self.remove_child(ball)
	self.get_parent().add_child(ball)
	ball.set_global_pos(ball_pos)
	ball.launch()

func spawn_ball():
	var ball = ball_scene.instance()
	add_child(ball)
	ball.set_pos(ball_spawn_pos.get_pos())
	ball.can_fall = true #if false, ball can bounc of ground
	ball.paddle = self #set ball paddle
	#connect ball signal to stage if present
	var stage = get_parent()
	if (stage.get_name() == "stage"):
		ball.connect("ball_fell", stage, "ball_fell")


func bounce_ball( ball ):
	#make sure the ball doesnt fall through the paddle
	var global_pos = ball.get_global_pos()
	if (global_pos.y > paddle_top_pos.get_global_pos().y):
		global_pos.y = paddle_top_pos.get_global_pos().y
		ball.set_global_pos(global_pos)
	ball.hit_something(G.TOP)
	print("ball bounce from paddle")
	

func _on_area_enter( area ):
	if (area extends preload("res://ball/ball.gd")):
		bounce_ball( area )
