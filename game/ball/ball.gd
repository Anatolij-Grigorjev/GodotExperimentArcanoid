extends Area2D

const BASE_BALL_SPEED = 100 #base ball speed

const COLOR_BLACK = Color(0.1, 0.1, 0.1)
const COLOR_WHITE = Color(1.0, 1.0, 1.0)
const COLOR_RED = Color(1.0, 0.1, 0.1)

const COLORS = [
	COLOR_RED, 
	COLOR_WHITE, 
	COLOR_BLACK
]

onready var anim = get_node("anim")
onready var sprite = get_node("sprite")

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
	direction = Vector2(randf() * 2.0 - 1, randf() * 2.0 - 1)
	speed = BASE_BALL_SPEED
	screen_rect = get_viewport_rect().size
	
	set_process(true)


func _process(delta):
	
	#hit the left wall going left, rebound as if hit right border of something
	if (get_global_pos().x < 0 and direction.x <= 0):
		hit_something(RIGHT)
	#hit right wall going right, rebound as if hit left border of something
	if (get_global_pos().x > screen_rect.x and direction.x >= 0):
		hit_something(LEFT)
	#hit top wall going up, rebound as if hit bottom border of something
	if (get_global_pos().y < 0 and direction.y <= 0):
		hit_something(BOTTOM)
	#hit bottom wall goind down, rbound as if hit top border of something
	if (get_global_pos().y > screen_rect.y and direction.y >= 0):
		hit_something(TOP)
		
	var new_pos = get_pos()
	new_pos += direction * speed * delta
	
	#integrate what happened
	set_pos(new_pos)
	
func hit_something(border_pos):
	
	#speed it up
	speed *= 1.1
	
	#switch animation
	if (anim.get_current_animation() == "spin_cw"):
		anim.play("spin_ccw")
	elif (anim.get_current_animation() == "spin_ccw"):
		anim.play("spin_cw")
		
	#switch color
	color_idx = (color_idx + 1) % COLORS.size()
	sprite.set_modulate(COLORS[color_idx])
	
	if (border_pos == LEFT or border_pos == RIGHT):
		direction.x *= -1
		#add a bit of fuzzyness to new direction
		direction.x *= (1 + (randf() * 2.0 - 1) / 10)
	if (border_pos == TOP or border_pos == BOTTOM):
		direction.y *= -1
		#add a bit of fuzzyness to new direction
		direction.y *= (1 + (randf() * 2.0 - 1) / 10)
		
	direction = direction.normalized()
	
	
	