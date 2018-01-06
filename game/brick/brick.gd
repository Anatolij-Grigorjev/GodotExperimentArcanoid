extends Node2D

onready var G = get_node("/root/game_state")

var color_idx setget set_color_idx

onready var sprite = get_node("sprite")
onready var sprite_shadow = get_node("sprite_shadow")
onready var anim = get_node("anim")

var brick_dead = false
var max_brick_health
var curr_brick_health setget set_brick_heatlh

func _ready():
	#num of damage sprites is brick total health
	max_brick_health = sprite.get_hframes()
	set_brick_health( max_brick_health )
	set_color_idx( 1 )
	

func set_brick_health( health ):
	curr_brick_health = health
	sprite.set_frame(curr_brick_health % max_brick_health)
	
func resolve_hit_with_pos( area, position ):
	if (area extends preload("res://ball/ball.gd") 
	and not brick_dead):
		hit_by_ball( area, position )


func hit_by_ball(ball, position):
	ball.hit_something(position)
	
	#ball differnt color, might have survived
	if (ball.color_idx != color_idx):
		set_brick_health( curr_brick_health - 1)
		anim.play("brick_damaged")
		if (curr_brick_health <= 0):
			destroy_brick()
	#ball same color as brick, kill it
	else:
		destroy_brick()
		
func destroy_brick():
	brick_dead = true
	#anim.play("brick_explode")
	
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
