extends Node2D

onready var G = get_node("/root/game_state")

var level_bricks_map = {}

onready var bricks = preload("res://brick/brick.tscn")

var brick_size = Vector2(250, 100)
var grid_area

func _ready():
	var json = G.get_current_level_json()
	var parse_result = level_bricks_map.parse_json(json)
	
	print("parse result of %s for %s" % [parse_result, json])
	
	var screen_size = get_viewport_rect().size
	grid_area = Vector2(screen_size.x, screen_size.y / 2)
	print("screen size: %s | grid area: %s" % [screen_size, grid_area])
	
	var r_padding = level_bricks_map.r_padding if level_bricks_map.has("r_padding") else 0
	var c_padding = level_bricks_map.c_padding if level_bricks_map.has("c_padding") else 0
	var layout = level_bricks_map.grid
	
	print("found %s row padding and %s column padding" % [r_padding, c_padding])
	
	#set grid position
	var rows_num = layout.size()
	var cells_num = layout[0].size() if rows_num > 0 else 0
	
	#no rows, no grid
	if (rows_num == 0 or cells_num == 0):
		return
		
	#calculate allowed brick size based on total viewport space
	var needed_w = (brick_size.x + c_padding) * cells_num - c_padding
	#how much to strech dimensions
	var w_zoom_coef = min(grid_area.x / needed_w, 1.0)
	#need to reduce brick.x
	if (w_zoom_coef < 1.0):
		brick_size.x *= w_zoom_coef
		c_padding *= w_zoom_coef
	var needed_h = (brick_size.y + r_padding) * rows_num - r_padding
	var h_zoom_coef = min(grid_area.y / needed_h, 1.0)
	#need to reduce brick.y
	if (h_zoom_coef < 1.0):
		brick_size.y *= h_zoom_coef
		r_padding *= h_zoom_coef
	
	print("found %s rows and %s columns for padding %s and brick size %s with zoom %s" % [
	rows_num, 
	cells_num, 
	Vector2(c_padding, r_padding), 
	brick_size,
	Vector2(w_zoom_coef, h_zoom_coef)
	])
	#rows - 1 number of bricks with padding and minus another brick
	#half of that is averaged height offset
	var h_offset = (grid_area.y - 
		((brick_size.y / 2 + r_padding) * rows_num - r_padding)) / 2
		
	#cells - 1 number of bricks with padding and minus another brick
	#half of that is averaged width offset
	var w_offset = (grid_area.x - 
		((brick_size.x / 2 + c_padding) * cells_num - c_padding)) / 2
	
	print("computed grid offset: W:%s H:%s" % [w_offset, h_offset])
	#set the offset
	set_pos(Vector2(w_offset, h_offset))
	
	make_instances_grid(layout, r_padding, c_padding, Vector2(w_zoom_coef, h_zoom_coef))
	
	pass


func make_instances_grid(grid_layout, row_pad, col_pad, scale):
	
	for row_idx in range(grid_layout.size()):
		var row = grid_layout[row_idx]
	
		for cell_idx in range(row.size()):
			var cell = row[cell_idx]
			if (cell != null):
				var a_brick = bricks.instance()
				add_child(a_brick)
				a_brick.set_scale(scale)
				a_brick.color_idx = G.COLOR_TO_IDX[cell]
				var brick_x = cell_idx * brick_size.x / 2 + cell_idx * col_pad
				var brick_y = row_idx * brick_size.y / 2 + row_idx * row_pad
				a_brick.set_pos(Vector2(brick_x, brick_y))
				print("brick %s, position: %s" % [a_brick, a_brick.get_pos()])
