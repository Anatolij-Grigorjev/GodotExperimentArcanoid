extends Area2D

onready var G = get_node("/root/game_state")

var BASE_BALL_SPEED = 150 #base ball speed
var BALL_SPEED_INCREASE = 1.1 #ball speed increase when bouncing

onready var anim = get_node("anim")
onready var sprite_shadow = get_node("sprite_shadow")

var direction = Vector2() #ball direction
var speed = 0 #current ball speed
var color_idx setget set_color_idx
var launched = false #is the ball in play

var screen_rect = Vector2()

func _ready():
	#initialize random direction
	screen_rect = get_viewport_rect()
	
	var extents = G.get_sprite_extents( get_node("sprite") )
	
	screen_rect.pos += extents
	screen_rect.end -= extents
	color_idx = 1
	
	
func launch():
	#launch somewhere up
	direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 0.0))
	speed = BASE_BALL_SPEED
	
	set_process(true)
	launched = true


func _process(delta):
	
	#hit the left wall going left, rebound as if hit right border of something
	if (get_global_pos().x < screen_rect.pos.x and direction.x <= 0):
		hit_something(G.RIGHT)
	#hit right wall going right, rebound as if hit left border of something
	if (get_global_pos().x > screen_rect.end.x and direction.x >= 0):
		hit_something(G.LEFT)
	#hit top wall going up, rebound as if hit bottom border of something
	if (get_global_pos().y < screen_rect.pos.y and direction.y <= 0):
		hit_something(G.BOTTOM)
	#hit bottom wall goind down, rbound as if hit top border of something
	if (get_global_pos().y > screen_rect.end.y and direction.y >= 0):
		hit_something(G.TOP)
		
	var new_pos = get_pos()
	new_pos += direction * speed * delta
	
	#integrate what happened
	set_pos(new_pos)
	
func hit_something(border_pos):
	#hits ignored while ball stationary
	if (not launched):
		return
	
	#speed it up
	speed *= BALL_SPEED_INCREASE
	
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
	
func set_color_idx( new_idx ):
	color_idx = new_idx % G.COLORS.size()
	sprite_shadow.set_modulate(G.COLORS[color_idx])