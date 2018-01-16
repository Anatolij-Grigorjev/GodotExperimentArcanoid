extends Control

onready var G = get_node("/root/game_state")

func _ready():
	

	for node in get_children():
		#launch balls
		if (node extends preload("res://ball/ball.gd")):
			node.launch()
		#secure bricks
		if (node extends preload("res://brick/brick.gd")):
			node.can_die = false
	
	
