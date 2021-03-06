extends KinematicBody2D

onready var G = get_node("/root/game_state")

const MAX_BOUNCE_COOLDOWN = 0.01
const COLOR_BLACK = Color(0, 0, 0)
const COLOR_WHITE = Color(1, 1, 1)

#max paddle move speed, limited by mouse as well
var max_move_speed 

onready var ball_spawn_pos = get_node("ball_spawn_pos")
onready var paddle_top_pos = get_node("paddle_top_pos")
onready var under_paddle_pos = get_node("under_paddle_pos")
onready var sprite = get_node("sprite")

var ball_scene = preload("res://ball/ball.tscn")


var prev_spawn_ball_pressed = false

#vector of movement bounds, screen size X minus sprite extents
var move_bounds

var paddle_rect

var just_bounced = false #did the ball just perform a bounce?
var bounce_cooldown = 0

var lives

func _ready():

	move_bounds = Vector2(0, get_viewport_rect().size.x)
	#try to get handle on lives UI (if this is a stage)
	lives = get_node("../lives")
	#obtain speed as a function of 
	#total disctance to cross in 1 second(-s)
	max_move_speed = move_bounds.y * 1.5
	
	var extents = G.get_sprite_extents( get_node("sprite") )
	paddle_rect = Rect2(get_pos(), extents * 2)
	
	#correct movement bounds
	move_bounds.x += extents.x
	move_bounds.y -= extents.x
	
	#intial spawn of ball is freebie
	spawn_ball(false)


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
		#if in stage, only allow ball spawning when there are balls to spawn
		if (lives != null):
			if (lives.num_lives > 0):
				spawn_ball()
		else:
			spawn_ball()
		
	update_bounce_cooldown(delta)
	
	var launch_ball_pressed = Input.is_action_pressed("launch_ball")
	if (launch_ball_pressed):
		#if action pressed and we have a ball to launch
		var child_ball = get_child_ball()
		if (child_ball != null):
			launch_ball( child_ball )
	prev_spawn_ball_pressed = spawn_ball_pressed
	
func update_bounce_cooldown(delta):
	if (just_bounced):
		if (bounce_cooldown <= 0):
			just_bounced = false
			sprite.set_modulate(COLOR_WHITE)
		else:
			bounce_cooldown -= delta

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

func spawn_ball(check_lives = true):
	if (check_lives):
		#spawning ball costs a life
		if (lives != null):
			#if there are lives to take then spawning is possible	
			if (lives.num_lives <= 0):
				lives.lost_life()
				#stop spawn if all lives lost
				return
			lives.lost_life()
	
	var ball = ball_scene.instance()
	add_child(ball)
	ball.set_pos(ball_spawn_pos.get_pos())
	ball.can_fall = true #if false, ball can bounc of ground
	ball.paddle = self #set ball paddle
	#connect ball signal to stage if present
	var stage = get_parent()
	if (stage.get_name() == "stage"):
		ball.connect("ball_fell", stage, "ball_fell")


func bounce_ball( ball, border_pos ):
	#make sure the ball doesnt fall through the paddle
	var global_pos = ball.get_global_pos()
	if (global_pos.y > paddle_top_pos.get_global_pos().y):
		global_pos.y = paddle_top_pos.get_global_pos().y
		ball.set_global_pos(global_pos)
	ball.hit_something(border_pos)
	just_bounced = true
	sprite.set_modulate(COLOR_BLACK)
	bounce_cooldown = MAX_BOUNCE_COOLDOWN
	
func is_bounceable_ball( area ):
	return area extends preload("res://ball/ball.gd") and not just_bounced

func central_bumper_enter( area ):
	if (is_bounceable_ball(area)):
		bounce_ball( area, G.TOP )

func left_bumper_enter( area ):
	if (is_bounceable_ball(area)):
		bounce_ball( area, G.L_SLOPE )
		
func right_bumper_enter( area ):
	if (is_bounceable_ball(area)):
		bounce_ball( area, G.R_SLOPE )
