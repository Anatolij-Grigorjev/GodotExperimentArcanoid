extends Control

onready var G = get_node("/root/game_state")

onready var level_lbl = get_node("level_panel/level_label")
onready var anim = get_node("anim")

func _ready():
	
	refresh_level_lbl()
	for node in get_children():
		#launch balls
		if (node extends preload("res://ball/ball.gd")):
			node.launch()
		#secure bricks
		if (node extends preload("res://brick/brick.gd")):
			node.can_die = false
	
func to_level_menu():
	anim.play("to_stage_select")
	
func to_main_menu():
	anim.play_backwards("to_stage_select")
	
func refresh_level_lbl():
	level_lbl.set_text("# %s" % (G.current_level_idx + 1))
	
