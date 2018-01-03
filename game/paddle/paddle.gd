extends KinematicBody2D


var max_move_speed = 110 #paddle move speed




func _ready():

	set_process(true)
	
func _process(delta):
	# mouse speed is returned same even when mouse stops moving, so need to check for that
	var mouse_moved = false
	
	if (mouse_moved):
		
		var new_pos = get_pos()
		var mouse_speed = Input.get_mouse_speed()
		
		new_pos.x += clamp(mouse_speed.x, 0, max_move_speed) * delta
	
