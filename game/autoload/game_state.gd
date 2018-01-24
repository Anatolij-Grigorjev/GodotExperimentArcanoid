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
const LEVELS_DIR = "res://stages"
const LEVELS_NAME_PATTERN = "level_"

var LEVEL_FILENAMES
var current_level_idx
var player_score
#are we entering main menu from level
var coming_from_level

#variable to store menu node after the player moved on to a game screen
var menu_node

func _ready():
	current_level_idx = 0
	player_score = 000000
	coming_from_level = false
	load_levels_filenames()
	
func load_levels_filenames():
	#atual array that will hold sorted levels
	LEVEL_FILENAMES = []
	#map that will relate level name number to level file name 
	var levels_map = {}
	#array of level indices within filenames 
	#(will be sorted before putting into final array)
	var indices = []
	
	var levels_dir = Directory.new()
	var dir_open = levels_dir.open(LEVELS_DIR)
	if (dir_open == OK):
		levels_dir.list_dir_begin()
		var file_name = levels_dir.get_next()
		while(file_name != ""):
			print("Dealing with file %s" % file_name)
			if (not levels_dir.current_is_dir()):
				#check filename follows convention
				if (file_name.begins_with(LEVELS_NAME_PATTERN)):
					var level_number = file_name.right(LEVELS_NAME_PATTERN.length())
					#file has extension
					var ext_idx = level_number.find(".")
					if (ext_idx != -1):
						level_number = level_number.left(ext_idx)
					#done, lets use this integer
					if (level_number.is_valid_integer()):
						indices.append(level_number.to_int())
						levels_map[level_number.to_int()] = file_name
			#fetch next file
			file_name = levels_dir.get_next()
		#loop over, time to sort indices
		indices.sort()
		for idx in indices:
			LEVEL_FILENAMES.append(levels_map[idx])
		#print levels just in case
		print("LEVEL_FILENAMES discovered: %s" % [LEVEL_FILENAMES])
	else:
		print("ERROR opening director %s: %s" % [LEVELS_DIR, dir_open])
	
	
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
	var filename = LEVEL_FILENAMES[current_level_idx]
	var file = File.new()
	var err = file.open(LEVELS_DIR.plus_file(filename), File.READ)
	if (err == OK):
		var text = file.get_as_text()
		file.close()
		return text
	else:
		print("Error opening level file %s: %s" % [filename, err])