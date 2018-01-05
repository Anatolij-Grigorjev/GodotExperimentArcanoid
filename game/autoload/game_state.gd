extends Node

const COLOR_BLACK = Color(0.1, 0.1, 0.1, 0.33)
const COLOR_WHITE = Color(1.0, 1.0, 1.0, 0.33)
const COLOR_RED = Color(1.0, 0.1, 0.1, 0.33)

const COLORS = [
	COLOR_RED, 
	COLOR_WHITE, 
	COLOR_BLACK
]

enum HIT_DIRECTIONS {
	TOP, 
	BOTTOM,
	LEFT, 
	RIGHT
}
	
func get_sprite_extents( sprite ):
	var tex = sprite.get_texture()
	return (tex.get_size() * sprite.get_scale()) * 0.5

func make_fuzzy(value, factor = 0.1):
	return value * rand_range(1 - factor, 1 + factor)