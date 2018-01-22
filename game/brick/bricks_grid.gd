extends Node2D

onready var G = get_node("/root/game_state")

var level_bricks_map = {}


onready var bricks = preload("res://brick/brick.tscn")


export var brick_size = Vector2(250, 100) #size of individual brick in pixels
export var grid_area = Vector2(1024, 300) #potential screen area the grid may take up
export var grid_padding = Vector2(0, 0) #padding between grid cells, x for horizontal, y vertical
export var rows_num = 0 #number of rows in grid
export var cells_num = 0 #number of cells in one row of the grid (columns) 
export var brick_scale_coef = Vector2() #brick size scaling factor with relation to amount of them onscreen

func _ready():
	var json = G.get_current_level_json()
	var parse_result = level_bricks_map.parse_json(json)
	
	print("parse result of %s for %s" % [parse_result, json])
	
	var layout = level_bricks_map.grid
	#set grid position
	rows_num = layout.size()
	cells_num = layout[0].size() if rows_num > 0 else 0
	#no rows, no grid
	if (rows_num == 0 or cells_num == 0):
		return
		
	set_grid_area()
	set_grid_padding()
	set_brick_scale_coef()
	set_grid_offset()
	
	make_instances_grid(layout)

func set_brick_scale_coef():
	#calculate allowed brick size based on total viewport space
	var needed_w = (brick_size.x + grid_padding.x) * cells_num - grid_padding.x
	#how much to strech dimensions
	var w_zoom_coef = min(grid_area.x / needed_w, 1.0)
	#need to reduce brick.x
	if (w_zoom_coef < 1.0):
		brick_size.x *= w_zoom_coef
		grid_padding.x *= w_zoom_coef
	var needed_h = (brick_size.y + grid_padding.y) * rows_num - grid_padding.y
	var h_zoom_coef = min(grid_area.y / needed_h, 1.0)
	#need to reduce brick.y
	if (h_zoom_coef < 1.0):
		brick_size.y *= h_zoom_coef
		grid_padding.y *= h_zoom_coef
	brick_scale_coef = Vector2(w_zoom_coef, h_zoom_coef)
	print("found %s rows and %s columns for padding %s and brick size %s with zoom %s" % [
	rows_num, 
	cells_num, 
	grid_padding, 
	brick_size,
	brick_scale_coef
	])

func set_grid_area():
	var screen_size = get_viewport_rect().size
	grid_area = Vector2(screen_size.x, screen_size.y / 2)
	print("screen size: %s | grid area: %s" % [screen_size, grid_area])
	
func set_grid_padding():
	var r_padding = level_bricks_map.r_padding if level_bricks_map.has("r_padding") else 0
	var c_padding = level_bricks_map.c_padding if level_bricks_map.has("c_padding") else 0
	grid_padding = Vector2(c_padding, r_padding)
	print("found grid padding %s" % grid_padding)

func set_grid_offset():
	#num of bricks with paddings minus one padding is amount of space needed
	#bricks extents are used instead of full sprite size becuase position is centered?
	var h_offset = (grid_area.y - 
		((brick_size.y / 2 + grid_padding.x) * rows_num - grid_padding.x)) / 2
		
	#cells - 1 number of bricks with padding and minus another brick
	#half of that is averaged width offset
	var w_offset = (grid_area.x - 
		((brick_size.x / 2 + grid_padding.y) * cells_num - grid_padding.y)) / 2
	
	print("computed grid offset: W:%s H:%s" % [w_offset, h_offset])
	#set the offset
	set_pos(Vector2(w_offset, h_offset))


func make_instances_grid(grid_layout):
	
	for row_idx in range(grid_layout.size()):
		var row = grid_layout[row_idx]
		for cell_idx in range(row.size()):
			var cell = row[cell_idx]
			if (cell != null):
				var a_brick = bricks.instance()
				add_child(a_brick)
				a_brick.set_scale(brick_scale_coef)
				a_brick.color_idx = G.COLOR_TO_IDX[cell]
				var brick_x = cell_idx * brick_size.x / 2 + cell_idx * grid_padding.x
				var brick_y = row_idx * brick_size.y / 2 + row_idx * grid_padding.y
				a_brick.set_pos(Vector2(brick_x, brick_y))
				print("brick %s, position: %s" % [a_brick, a_brick.get_pos()])
