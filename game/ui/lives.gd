extends HBoxContainer

export var max_num_lives = 3 
export var num_lives = 0 setget set_num_lives #current number of remaning lives

onready var life_tex = preload("res://ball/ball.png")

var lives_list = []

signal all_lives_lost

func _ready():
	
	set_num_lives(max_num_lives)
	

func clear_children():
	for child in get_children():
		if (child extends TextureFrame):
			child.queue_free()

func set_num_lives( lives ):
	
	clear_children()
	lives_list = []
	for idx in range(lives):
		var a_life = TextureFrame.new()
		a_life.set_texture(life_tex)
		add_child(a_life)
		lives_list.append(a_life)

func lost_life():
	if (lives_list.empty()):
		emit_signal("all_lives_lost")
		return
	else:
		var lost_life = lives_list.back()
		lives_list.pop_back()
		lost_life.queue_free()
	
