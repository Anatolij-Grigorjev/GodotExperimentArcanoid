extends CenterContainer

export var max_lives = 3

export var num_lives = 1 setget set_num_lives

var padding_w = 10
var padding_h = 5

var CONTAINER_HEIGHT = 50

var life_height = CONTAINER_HEIGHT - padding_h * 2

var life_clazz = preload("player_life.tscn")

func _ready():
	
	#set_num_lives( max_lives )
	print(get_size())
	set_global_pos(Vector2(100, 100))
	print("children: %s, size: %s" % [get_child_count(), get_children()[0].get_size()])
	
func clear_lives():
	for child in get_children():
		child.queue_free()
	
func set_num_lives( num ):
	clear_lives()
	num_lives = num
	#width of container is padding on left and all lives + padding after every
	var container_width = padding_w + (life_height + padding_w) * num_lives
	
	for life_idx in range(num_lives):
		var a_life = life_clazz.instance()
		add_child(a_life)
		a_life.set_size(Vector2(life_height, life_height))
		a_life.set_pos(Vector2(life_idx * life_height + padding_w * life_idx, 0))
	
	set_size(Vector2(container_width, CONTAINER_HEIGHT))
	update()
