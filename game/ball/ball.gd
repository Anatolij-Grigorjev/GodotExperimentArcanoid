extends Area2D

const COLOR_BLACK = Color(0.1, 0.1, 0.1, 0.5)
const COLOR_WHITE = Color(1.0, 1.0, 1.0, 0.5)
const COLOR_RED = Color(1.0, 0.1, 0.1, 0.5)


var BASE_BALL_SPEED = 150 #base ball speed
var BALL_SPEED_INCREASE = 1.1 #ball speed increase when bouncing

const COLORS = [
	COLOR_RED, 
	COLOR_WHITE, 
	COLOR_BLACK
]

onready var anim = get_node("anim")
onready var sprite_shadow = get_node("sprite_shadow")

var direction = Vector2() #ball direction
var speed = 0 #current ball speed
var color_idx = 1

enum HIT_DIRECTIONS {
	TOP, 
	BOTTOM,
	LEFT, 
	RIGHT
}

var screen_rect = Vector2()

func _ready():
	#initialize random direction
	direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
	speed = BASE_BALL_SPEED
	screen_rect = get_viewport_rect()
	
	var sprite = get_node("sprite")
	var tex = sprite.get_texture()
	var extents = (tex.get_size() * sprite.get_scale()) * 0.5
	
	screen_rect.pos += extents
	screen_rect.end -= extents
	
	set_process(true)


func _process(delta):
	
	#hit the left wall going left, rebound as if hit right border of something
	if (get_global_pos().x < screen_rect.pos.x and direction.x <= 0):
		hit_something(RIGHT)
	#hit right wall going right, rebound as if hit left border of something
	if (get_global_pos().x > screen_rect.end.x and direction.x >= 0):
		hit_something(LEFT)
	#hit top wall going up, rebound as if hit bottom border of something
	if (get_global_pos().y < screen_rect.pos.y and direction.y <= 0):
		hit_something(BOTTOM)
	#hit bottom wall goind down, rbound as if hit top border of something
	if (get_global_pos().y > screen_rect.end.y and direction.y >= 0):
		hit_something(TOP)
		
	var new_pos = get_pos()
	new_pos += direction * speed * delta
	
	#integrate what happened
	set_pos(new_pos)
	
func hit_something(border_pos):
	
	#speed it up
	speed *= BALL_SPEED_INCREASE
	
	#switch animation
	if (anim.get_current_animation() == "spin_cw"):
		anim.play("spin_ccw")
	elif (anim.get_current_animation() == "spin_ccw"):
		anim.play("spin_cw")
		
	#switch color
	color_idx = (color_idx + 1) % COLORS.size()
	sprite_shadow.set_modulate(COLORS[color_idx])
	
	if (border_pos == LEFT or border_pos == RIGHT):
		direction.x *= -1
		#add a bit of fuzzyness to new direction
		direction.x = make_fuzzy(direction.x)
	if (border_pos == TOP or border_pos == BOTTOM):
		direction.y *= -1
		#add a bit of fuzzyness to new direction
		direction.y = make_fuzzy(direction.y)
		
	direction = direction.normalized()
	
func make_fuzzy(value, factor = 0.1):
	return value * rand_range(1 - factor, 1 + factor)
	
	