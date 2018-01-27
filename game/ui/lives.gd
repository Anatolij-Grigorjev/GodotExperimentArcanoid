extends TextureFrame

onready var G = get_node("/root/game_state")
onready var lives_lbl = get_node("lives_lbl")
onready var anim = get_node("anim")

export var max_num_lives = 3 
export var num_lives = 0

signal all_lives_lost

func _ready():
	set_num_lives(max_num_lives)

func set_num_lives( lives ):
	num_lives = lives
	lives_lbl.set_text(str(lives))

func lost_life():
	if (num_lives <= 0):
		emit_signal("all_lives_lost")
		return
	else:
		set_num_lives(num_lives - 1)
		
func add_life():
	print("adding life")
	set_num_lives(num_lives + 1)
	anim.play("life_up")
	