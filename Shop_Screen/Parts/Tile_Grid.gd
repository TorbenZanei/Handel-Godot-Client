extends Node

var grid = []

func _ready():
	pass

func set_tiles(grid_data):
	grid = grid_data

func check_room_wall(room):
	var tiles = room.room_member
	var wall_compleat = true
	
	for tile in tiles:
		if(wall_compleat):
			wall_compleat = check_surrounding(tile, room)
	
	if(!wall_compleat):
		room.room_constructable = false
		room.shop_constructable = false

func check_if_wall_deletable(tile):
	var deletable = true
	var wall_place = tile.coordinates
	var sw = [] #surrounding walls
	
	sw.append(get_tile_state(grid[wall_place[1] - 1][wall_place[0] - 1]))
	sw.append(get_tile_state(grid[wall_place[1] - 1][wall_place[0]]))
	sw.append(get_tile_state(grid[wall_place[1] - 1][wall_place[0] + 1]))
	
	sw.append(get_tile_state(grid[wall_place[1]][wall_place[0] - 1]))
	sw.append(get_tile_state(grid[wall_place[1]][wall_place[0] + 1]))
	
	sw.append(get_tile_state(grid[wall_place[1] + 1][wall_place[0] - 1]))
	sw.append(get_tile_state(grid[wall_place[1] + 1][wall_place[0]]))
	sw.append(get_tile_state(grid[wall_place[1] + 1][wall_place[0] + 1]))
	
	#Wand ist keine benötigte Ecke
	if(sw[1] == 1 && sw[4] == 1 && (sw[2] == 2 || (sw[3] == 2 && sw[5] == 2 && sw[6] == 2))): deletable = false
	if(sw[4] == 1 && sw[6] == 1 && (sw[7] == 2 || (sw[0] == 2 && sw[1] == 2 && sw[3] == 2))): deletable = false
	if(sw[6] == 1 && sw[3] == 1 && (sw[5] == 2 || (sw[1] == 2 && sw[2] == 2 && sw[4] == 2))): deletable = false
	if(sw[3] == 1 && sw[1] == 1 && (sw[0] == 2 || (sw[4] == 2 && sw[6] == 2 && sw[7] == 2))): deletable = false
	
	if(sw[0] == 1 && sw[1] == 1 && sw[3] == 1): deletable = true
	if(sw[1] == 1 && sw[2] == 1 && sw[4] == 1): deletable = true
	if(sw[4] == 1 && sw[6] == 1 && sw[7] == 1): deletable = true
	if(sw[3] == 1 && sw[5] == 1 && sw[6] == 1): deletable = true
	
	#Wand ist keine benötigtes T-Stück
	if(sw[1] == 1 && sw[4] == 1 && sw[3] == 1 && (sw[0] == 2 || sw[2] == 2 || (sw[5] == 2 || sw[6] == 2 || sw[7] == 2))): deletable = false
	if(sw[4] == 1 && sw[6] == 1 && sw[1] == 1 && (sw[2] == 2 || sw[7] == 2 || (sw[0] == 2 || sw[3] == 2 || sw[5] == 2))): deletable = false
	if(sw[6] == 1 && sw[3] == 1 && sw[4] == 1 && (sw[5] == 2 || sw[7] == 2 || (sw[0] == 2 || sw[1] == 2 || sw[2] == 2))): deletable = false
	if(sw[3] == 1 && sw[1] == 1 && sw[6] == 1 && (sw[0] == 2 || sw[5] == 2 || (sw[2] == 2 || sw[4] == 2 || sw[7] == 2))): deletable = false
	
	if(sw[0] == 1 && sw[1] == 1 && sw[3] == 1 && sw[5] == 1 && sw[6] == 1): deletable = true
	if(sw[0] == 1 && sw[1] == 1 && sw[2] == 1 && sw[3] == 1 && sw[4] == 1): deletable = true
	if(sw[1] == 1 && sw[2] == 1 && sw[4] == 1 && sw[6] == 1 && sw[7] == 1): deletable = true
	if(sw[3] == 1 && sw[4] == 1 && sw[5] == 1 && sw[6] == 1 && sw[7] == 1): deletable = true
	
	#Wand ist kein benötigtes Kreuz
	if(sw[1] == 1 && sw[3] == 1 && sw[4] == 1 && sw[6] == 1 && (sw[0] == 2 || sw[2] == 2 || sw[5] == 2 || sw[7] == 2)): deletable = false
	
	return deletable

func check_surrounding(tile, room):
	var allowed = true
	
	if(!(tile.top_tile.left_tile.state == 2 || tile.top_tile.left_tile.room == room)): allowed = false
	if(!(tile.top_tile.state == 2 || tile.top_tile.room == room)): allowed = false
	if(!(tile.top_tile.right_tile.state == 2 || tile.top_tile.right_tile.room == room)): allowed = false
	if(!(tile.left_tile.state == 2 || tile.left_tile.room == room)): allowed = false
	if(!(tile.right_tile.state == 2 || tile.right_tile.room == room)): allowed = false
	if(!(tile.bot_tile.left_tile.state == 2 || tile.bot_tile.left_tile.room == room)): allowed = false
	if(!(tile.bot_tile.state == 2 || tile.bot_tile.room == room)): allowed = false
	if(!(tile.bot_tile.right_tile.state == 2 || tile.bot_tile.right_tile.room == room)): allowed = false
	
	return allowed

func get_tile_state(tile):
	# 0 frei 1 mauer 2 raum 
	var state 
	if(tile.state == 1 && tile.room == null):
		state = 0
	elif(tile.state == 2):
		state = 1
	elif(tile.state == 1 && tile.room != null):
		state = 2
	
	return state

func get_tile(x, y):
	return grid[y][x]

func get_tile_area(x_area, y_area):
	var tile_area = []
	var area_row
	
	var x_range = 6
	var y_range = 6
	
	var x_extra = 1
	var y_extra = 1
	
	if(x_area == 0):
		x_range = 7
		x_extra = 0
	
	if(y_area == 0):
		y_range = 7
		y_extra = 0
	
	for y in range(7):
		area_row = []
		for x in range(7):
			area_row.append(grid[y + y_area * 5][x + x_area * 5])
		tile_area.append(area_row)
	
	return tile_area
