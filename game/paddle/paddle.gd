extends KinematicBody2D


var max_move_speed #max paddle move speed, limited by mouse as well

#vector of movement bounds, screen size - sprite extents
var move_bounds

func _ready():

	move_bounds = Vector2(0, get_viewport_rect().size.x)
	
	#obtain speed as a function of 
	#total disctance to cross in 1 second(-s)
	max_move_speed = move_bounds.y
	
	var sprite = get_node("sprite")
	var tex = sprite.get_texture()
	var extents = (tex.get_size() * sprite.get_scale()) * 0.5
	
	#correct movement bounds
	move_bounds.x += extents.x
	move_bounds.y -= extents.x
	
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
	


func bounce_ball( ball ):
	
	ball.hit_something(ball.TOP)
	

func _on_area_enter( area ):
	if (area extends preload("res://ball/ball.gd")):
		bounce_ball( area )
