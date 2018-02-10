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
const LEVEL_UP_MILESTONES = [
	500,
	1000,
	1500
]

var LEVEL_HIGHSCORES = {}



const TOP = 50
const BOTTOM = 51
const LEFT = 52
const RIGHT = 53
const L_SLOPE = 54
const R_SLOPE = 55

const LEVELS_DIR = "res://stages"
const LEVEL_NAMES_FILE = "res://menus/level_names.json"
const LEVELS_NAME_PATTERN = "level_"
const MAX_LIVES = 5

var LEVEL_FILENAMES
var LEVEL_NAMES
var current_level_idx
#last recorded player score before starting stage
#used to offset highscore
var pre_stage_score
var player_score setget set_player_score
#are we entering main menu from level
var coming_from_level

var remaining_lives

#variable to store menu node after the player moved on to a game screen
var menu_node

func _ready():
	#sort level up milestones in ascending order just in case
	LEVEL_UP_MILESTONES.sort()
	remaining_lives = MAX_LIVES
	current_level_idx = 0
	player_score = 000000
	pre_stage_score = player_score
	coming_from_level = false
	load_levels_filenames()
	load_level_names()
	
func load_level_names():
	LEVEL_NAMES = []
	var json_text = get_file_text(LEVEL_NAMES_FILE)
	var names_obj = {}
	names_obj.parse_json(json_text)
	for name in names_obj.names:
		LEVEL_NAMES.append(name)
	
	
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
		
func get_stage_highscore(idx = current_level_idx):
	if (LEVEL_HIGHSCORES.has(idx)):
		return LEVEL_HIGHSCORES[idx]
	else:
		return 0

func tryset_stage_score(score, idx = current_level_idx):
	if (not LEVEL_HIGHSCORES.has(idx)):
		LEVEL_HIGHSCORES[idx] = score
	else:
		LEVEL_HIGHSCORES[idx] = max(LEVEL_HIGHSCORES[idx], score) 
		
func set_player_score(score):
	player_score = score
	#skip this part if no more milestones
	if (LEVEL_UP_MILESTONES.empty()):
		return
	for milestone in LEVEL_UP_MILESTONES:
		if (player_score > milestone):
			#find lives node in stage
			var lives = get_node("/root/stage/lives")
			if (lives != null):
				lives.add_life()
			LEVEL_UP_MILESTONES.pop_front()
			return
	return
	
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
	return get_file_text(LEVELS_DIR.plus_file(filename))
		
func get_file_text(filename):
	var file = File.new()
	var err = file.open(filename, File.READ)
	if (err == OK):
		var text = file.get_as_text()
		file.close()
		return text
	else:
		print("Error opening level file %s: %s" % [filename, err])