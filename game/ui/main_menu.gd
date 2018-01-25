extends Control

onready var G = get_node("/root/game_state")

const MENU_ANIMATION_LENGTH = 2.5

onready var level_lbl = get_node("level_panel/level_label")
onready var anim = get_node("anim")
onready var lives = get_node("lives_ball")

onready var level_prev_btn = get_node("level_prev")
onready var level_next_btn = get_node("level_next")

onready var stage = preload("res://stages/stage.tscn")

func _ready():
	G.menu_node = self
	if (G.coming_from_level):
		#advance animation to level selection
		anim.seek(MENU_ANIMATION_LENGTH, true)
		#reset coming from level
		G.coming_from_level = false
	lives.set_num_lives(G.remaining_lives)
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
	level_lbl.set_text(G.LEVEL_NAMES[G.current_level_idx])
	
func next_stage():
	G.current_level_idx += 1
	validate_level_idx()
	
func prev_stage():
	G.current_level_idx -= 1
	validate_level_idx()
	
func validate_level_idx():
	G.current_level_idx = clamp(G.current_level_idx, 0, G.LEVEL_FILENAMES.size() - 1)
	refresh_level_lbl()
	#cycled to first level in selection
	validate_page_button(
	level_prev_btn, 
	G.current_level_idx == 0,
	"<" + str(G.current_level_idx)) #display prev level number
	
	#cycled to last level in selection
	validate_page_button(
	level_next_btn, 
	G.current_level_idx == G.LEVEL_FILENAMES.size() - 1,
	str(G.current_level_idx + 2) + ">") #display next level number


func validate_page_button(button, disabled_cond, enabled_text):
	if (disabled_cond):
		button.set_disabled(true)
		button.set_text("")
	else:
		button.set_disabled(false)
		button.set_text(enabled_text)


func play():
	#keep menu cached in game state after switching to stage
	get_tree().get_root().add_child(stage.instance())
	anim.seek(0.0, true)
	get_tree().get_root().remove_child(self)
	
func exit():
	get_tree().quit()
	
	
	
	
	
