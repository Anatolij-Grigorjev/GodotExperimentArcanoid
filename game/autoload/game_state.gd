extends Node

const COLOR_BLACK = Color(0.1, 0.1, 0.1, 0.4)
const COLOR_WHITE = Color(1.0, 1.0, 1.0, 0.4)
const COLOR_RED = Color(1.0, 0.1, 0.1, 0.4)

const COLORS = [
	COLOR_RED, 
	COLOR_WHITE, 
	COLOR_BLACK
]

const COLOR_TO_IDX = {
	"R": 0,
	"W": 1, 
	"B": 2
}

enum HIT_DIRECTIONS {
	TOP, 
	BOTTOM,
	LEFT, 
	RIGHT
}

var LEVELS = [
	"level_1.json"
]

var current_level_idx

var player_score

func _ready():
	current_level_idx = 0
	player_score = 000000
	
func get_sprite_extents( sprite ):
	var tex = sprite.get_texture()
	var tex_size = tex.get_size()
	var h_frames = sprite.get_hframes()
	var v_frames = sprite.get_vframes()
	tex_size.x /= h_frames
	tex_size.y /= v_frames
	return (tex_size * sprite.get_scale()) * 0.5

func make_fuzzy(value, factor = 0.1):
	return value * rand_range(1 - factor, 1 + factor)
	
#fetch the level json and closes file after itself
func get_current_level_json():
	var filename = LEVELS[current_level_idx]
	var file = File.new()
	var err = file.open("res://stages/%s" % filename, File.READ)
	if (err == OK):
		var text = file.get_as_text()
		file.close()
		return text
	else:
		print("Error opening level file %s: %s" % [filename, err])