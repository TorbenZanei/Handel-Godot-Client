extends Node

var area_position
var tile_area
var selected = false

func _ready():
	pass

func position_area(x, y):
	area_position = [x,y]
	tile_area = GV.shop_screen.tile_grid.get_tile_area(x, y)
	for row in tile_area:
		for tile in row:
			tile.connect("mouse_entered",self,"highlight_on", [tile])
			tile.connect("mouse_exited",self,"highlight_off", [tile])
			tile.set_construct_mode(1)

func aboart_construction():
	for row in tile_area:
		for tile in row:
			tile.set_construct_mode(0)
			tile.highlight(0)
	queue_free()

func highlight_on(tile):
	if(GV.shop_screen.action_on_request == null):
		var has_tile = false
		for row in tile_area:
			if(row.has(tile)):
				has_tile = true
		
		if(!GV.conformation_request_visible):
			if(has_tile):
				for row in tile_area:
					for tile in row:
						tile.highlight(3, true)
			if(!GV.await_server_answer):
				GV.shop_screen.action_on_request = self

func highlight_off(tile):
	var has_tile = false
	for row in tile_area:
		if(row.has(tile)):
			has_tile = true
	
	if(!GV.conformation_request_visible):
		if(has_tile):
			for row in tile_area:
				for tile in row:
					tile.highlight(1, true)
			
		if(!GV.await_server_answer):
			GV.shop_screen.action_on_request = null
