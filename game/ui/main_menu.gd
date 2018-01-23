extends Control

onready var G = get_node("/root/game_state")

onready var level_lbl = get_node("level_panel/level_label")
onready var anim = get_node("anim")

onready var level_prev_btn = get_node("level_prev")
onready var level_next_btn = get_node("level_next")

onready var stage = preload("res://stages/stage.tscn")

func _ready():
	G.menu_node = self
	if (G.coming_from_level):
		#advance animation to level selection
		anim.seek(2.5, true)
		#reset coming from level
		G.coming_from_level = false
	validate_level_idx()
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
	
func next_stage():
	G.current_level_idx += 1
	validate_level_idx()
	
func prev_stage():
	G.current_level_idx -= 1
	validate_level_idx()
	
func validate_level_idx():
	G.current_level_idx = clamp(G.current_level_idx, 0, G.LEVELS.size() - 1)
	refresh_level_lbl()
	level_prev_btn.set_disabled(G.current_level_idx == 0)
	level_next_btn.set_disabled(G.current_level_idx == G.LEVELS.size() - 1)
	
func play():
	#TODO: need better way of stopping menu activity
	#keep menu cached in autoload with inactive state?
	get_tree().get_root().add_child(stage.instance())
	anim.seek(0.0, true)
	get_tree().get_root().remove_child(self)
	
func exit():
	get_tree().quit()
	
	
	
	
	
