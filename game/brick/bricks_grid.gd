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
	
	var r_padding = level_bricks_map.r_pading if level_bricks_map.has("r_padding") else 0
	var c_padding = level_bricks_map.c_padding if level_bricks_map.has("c_padding") else 0
	var layout = level_bricks_map.grid
	
	print("found %s row padding and %s column padding" % [r_padding, c_padding])
	
	#set grid position
	var rows_num = layout.size()
	var cells_num = layout[0].size() if rows_num > 0 else 0
	
	print("found %s rows and %s columns" % [rows_num, cells_num])
	#rows - 1 number of bricks with padding and minus another brick
	#half of that is averaged height offset
	var h_offset = (grid_area.y - 
		((brick_size.y + r_padding) * (rows_num - 1) + brick_size.y)) / 2
		
	#cells - 1 number of bricks with padding and minus another brick
	#half of that is averaged width offset
	var w_offset = (grid_area.x - 
		((brick_size.x + c_padding) * (cells_num - 1) + brick_size.x)) / 2
	
	print("computed grid offset: W:%s H:%s" % [w_offset, h_offset])
	#set the offset
	set_pos(Vector2(w_offset, h_offset))
	
	make_instances_grid(layout, r_padding, c_padding)
	
	pass


func make_instances_grid(grid_layout, row_pad, col_pad):
	
	for row_idx in range(grid_layout.size()):
		var row = grid_layout[row_idx]
	
		for cell_idx in range(row.size()):
			var cell = row[cell_idx]
			if (cell != null):
				var a_brick = bricks.instance()
				add_child(a_brick)
				a_brick.color_idx = G.COLOR_TO_IDX[cell]
				var brick_x = cell_idx * brick_size.x + cell_idx * col_pad
				var brick_y = row_idx * brick_size.y + row_idx * row_pad
				a_brick.set_pos(Vector2(brick_x, brick_y))
