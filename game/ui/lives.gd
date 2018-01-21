extends TextureFrame

onready var lives_lbl = get_node("lives_lbl")

export var max_num_lives = 3 
export var num_lives = 0

signal all_lives_lost

func _ready():
	for child in get_children():
		print("%s: %s" % [child.get_name(), child])
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