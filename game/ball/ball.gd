extends Area2D

onready var G = get_node("/root/game_state")

var BASE_BALL_SPEED = 150 #base ball speed
var MAX_BALL_SPEED = 700 #max speed ball can achieve
var HALF_BALL_SPEED = MAX_BALL_SPEED / 2 #half max speed of ball
var BALL_SPEED_MULTIPLIER = 1.1 #ball speed increase when bouncing at low speeds
var BALL_SPEED_ADDITIVE = 45 #ball speed addition on higher speeds for bouncing

var LAUNCH_ANGLE_FUNNEL = 15 #degrees of launch funnel not to launch at extreme ends

onready var anim = get_node("anim")
onready var sprite_shadow = get_node("sprite_shadow")

var direction = Vector2() #ball direction
var speed = 0 #current ball speed
var color_idx setget set_color_idx
var launched = false #is the ball in play
var can_fall = false #by default ball cant fall, is demo
var screen_rect = Vector2()

signal ball_fell

func _ready():
	#initialize random direction
	screen_rect = get_viewport_rect()
	
	var extents = G.get_sprite_extents( get_node("sprite") )
	
	screen_rect.pos += extents
	screen_rect.end -= extents
	color_idx = 1
	
	
func launch():
	#launch somewhere up
	var angle = rand_range(LAUNCH_ANGLE_FUNNEL, 180 - LAUNCH_ANGLE_FUNNEL) #random angle from ~0 to ~PI
	var rad_angle = deg2rad(angle)
	#angle of sin will always be positive, need opposite
	direction = Vector2(cos(rad_angle), -sin(rad_angle))
	print("launching ball %s at direction %s from angle %s" % [self, direction, angle])
	speed = BASE_BALL_SPEED
	
	set_process(true)
	launched = true


func _process(delta):
	
	bounce_screen_bounds()
	
	var speed_up_pressed = Input.is_action_pressed("ball_speed_up")
	if (speed_up_pressed):
		increase_speed()
	
	var new_pos = get_pos()
	new_pos += direction * speed * delta
	
	#integrate what happened
	set_pos(new_pos)
	
func bounce_screen_bounds():
	#hit the left wall going left, rebound as if hit right border of something
	if (get_global_pos().x < screen_rect.pos.x and direction.x <= 0):
		hit_something(G.RIGHT)
	#hit right wall going right, rebound as if hit left border of something
	if (get_global_pos().x > screen_rect.end.x and direction.x >= 0):
		hit_something(G.LEFT)
	#hit top wall going up, rebound as if hit bottom border of something
	if (get_global_pos().y < screen_rect.pos.y and direction.y <= 0):
		hit_something(G.BOTTOM)
	#hit bottom wall goind down, ball lost forever
	if (can_fall):
		if (get_global_pos().y > (screen_rect.end.y + sprite_shadow.get_texture().get_height()) and direction.y >= 0):
			emit_signal("ball_fell")
			set_process(false)
			return
	else:
		if (get_global_pos().y > screen_rect.end.y and direction.y >= 0):
			hit_something(G.TOP)

	
func hit_something(border_pos):
	#hits ignored while ball stationary
	if (not launched):
		return
	
	#speed it up
	increase_speed()
	
	#switch animation
	if (anim.get_current_animation() == "spin_cw"):
		anim.play("spin_ccw")
	elif (anim.get_current_animation() == "spin_ccw"):
		anim.play("spin_cw")
		
	#cycle colors
	set_color_idx( color_idx + 1 )
	
	if (border_pos == G.LEFT or border_pos == G.RIGHT):
		direction.x *= -1
		#add a bit of fuzzyness to new direction
		direction.x = G.make_fuzzy(direction.x)
	if (border_pos == G.TOP or border_pos == G.BOTTOM):
		direction.y *= -1
		#add a bit of fuzzyness to new direction
		direction.y = G.make_fuzzy(direction.y)
		
	direction = direction.normalized()

func increase_speed():
	#if the ball is at its highest speed already, leave it at that
	if (speed >= MAX_BALL_SPEED):
		return

	#if the ball is above 1/2 of max speed
	#we use addition to gain speed more slowly
	if (speed >= HALF_BALL_SPEED):
		speed += BALL_SPEED_ADDITIVE
	
	#if the ball is below 1/2 of max speed, 
	#we multiply its speed by the percentage
	if (speed < HALF_BALL_SPEED):
		speed *= BALL_SPEED_MULTIPLIER	
	
	#clamp the speed to ensure correct intervals
	speed = clamp(speed, BASE_BALL_SPEED, MAX_BALL_SPEED)
	
	
func set_color_idx( new_idx ):
	color_idx = new_idx % G.COLORS.size()
	sprite_shadow.set_modulate(G.COLORS[color_idx])