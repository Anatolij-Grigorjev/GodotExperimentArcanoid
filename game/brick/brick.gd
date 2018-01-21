extends Node2D

onready var G = get_node("/root/game_state")

var color_idx setget set_color_idx

onready var sprite = get_node("sprite")
onready var sprite_shadow = get_node("sprite_shadow")
onready var anim = get_node("anim")
onready var brick_label = get_node("brick_value")

var brick_dead = false
var can_die = true #is the brick succeptible to hits
var max_brick_health
var curr_brick_health setget set_brick_health

var brick_score_value setget set_brick_score_value

signal brick_destroyed(brick_points)

func _ready():
	#num of damage sprites is brick total health
	max_brick_health = sprite.get_hframes()
	set_brick_health( max_brick_health )
	set_color_idx( 1 )
	set_brick_score_value(100)
	
func set_brick_score_value(new_val):
	brick_score_value = new_val
	brick_label.set_text(str(brick_score_value))

func set_brick_health( health ):
	curr_brick_health = health
	sprite.set_frame(curr_brick_health % max_brick_health)
	sprite_shadow.set_frame(curr_brick_health % max_brick_health)
	
func resolve_hit_with_pos( area, position ):
	if (area extends preload("res://ball/ball.gd") 
	and not brick_dead):
		hit_by_ball( area, position )


func hit_by_ball(ball, position):
	ball.hit_something(position)
	#resolve brick problems if it can actually die
	if (can_die):
		#ball differnt color, might have survived
		if (ball.color_idx != color_idx):
			set_brick_health( curr_brick_health - 1)
			anim.play("brick_damaged")
			if (curr_brick_health <= 0):
				destroy_brick()
		#ball same color as brick, kill it
		#double score if color was same as ball
		else:
			destroy_brick(true)
		
func destroy_brick(color_death = false):
	brick_dead = true
	var multiplier = 2 if color_death else 1
	var brick_value = multiplier * brick_score_value
	set_brick_score_value(brick_value)
	anim.play("brick_death")
	emit_signal("brick_destroyed", brick_value)

	
func set_color_idx( new_idx ):
	color_idx = new_idx % G.COLORS.size()
	sprite_shadow.set_modulate(G.COLORS[color_idx])

func _on_brick_top_area_enter( area ):
	resolve_hit_with_pos( area, G.TOP )


func _on_brick_left_area_enter( area ):
	resolve_hit_with_pos( area, G.LEFT )


func _on_brick_bottom_area_enter( area ):
	resolve_hit_with_pos( area, G.BOTTOM )


func _on_brick_right_area_enter( area ):
	resolve_hit_with_pos( area, G.RIGHT )
