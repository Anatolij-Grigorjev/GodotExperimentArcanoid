extends KinematicBody2D

onready var G = get_node("/root/game_state")

#max paddle move speed, limited by mouse as well
var max_move_speed 

onready var ball_spawn_pos = get_node("ball_spawn_pos")
var ball_scene = preload("res://ball/ball.tscn")

#vector of movement bounds, screen size X minus sprite extents
var move_bounds

func _ready():

	move_bounds = Vector2(0, get_viewport_rect().size.x)
	
	#obtain speed as a function of 
	#total disctance to cross in 1 second(-s)
	max_move_speed = move_bounds.y
	
	var extents = G.get_sprite_extents( get_node("sprite") )
	
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
	
	var launch_ball = Input.is_action_pressed("launch_ball")
	#if action pressed and we have a ball to launch
	if (launch_ball and has_node("ball")):
		var ball = get_node("ball")
		var ball_pos = ball.get_global_pos()
		self.remove_child(ball)
		self.get_parent().add_child(ball)
		ball.set_global_pos(ball_pos)
		ball.launch()
	

func spawn_ball():
	var ball = ball_scene.instance()
	add_child(ball)
	ball.set_pos(ball_spawn_pos.get_pos())


func bounce_ball( ball ):
	ball.hit_something(G.TOP)
	

func _on_area_enter( area ):
	if (area extends preload("res://ball/ball.gd")):
		bounce_ball( area )
