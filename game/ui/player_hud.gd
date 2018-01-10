extends Control

var screen_size

export var max_lives = 3

var player_lives_clazz = preload("player_lives.tscn")

func _ready():
	
	screen_size = get_viewport_rect().size
	
	set_size(screen_size)
	
	var player_lives = player_lives_clazz.instance()
	add_child(player_lives)
	player_lives.num_lives = 2
	
	player_lives.set_pos(
	Vector2(
	100,#screen_size.x - player_lives.get_size().x - get_margin(MARGIN_RIGHT),
	get_margin(MARGIN_TOP)
	))
	
	for child in player_lives.get_children():
		print("%s, pos: %s" % [child, child.get_pos()])
	
	print("lives num: %s at pos: %s and size: %s" % [player_lives.num_lives, player_lives.get_pos(), player_lives.get_size()])
	
