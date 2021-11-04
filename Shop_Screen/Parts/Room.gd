extends Node

var room_id
var room_kind

var room_member = []
var path_member = []
var preview_room = true
var room_constructable = false
var shop_constructable = false

var enhancing_funiture = []
var bonus = 0

func _init(kind = 0, id = 0):
	room_id = id
	room_kind = kind

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_member(tile):
	if(!room_member.has(tile)):
		room_member.append(tile)
		return true
	else:
		return false

func show_if_possible(on_off):
	if(on_off):
		if(room_kind < 3 && room_constructable || room_kind == 3 && shop_constructable):
			group_highlight(3)
		else:
			group_highlight(2)
	else:
		group_highlight(0)

func group_highlight(id):
	for i in range(room_member.size()):
		room_member[i].highlight(id)

func reset_preview_room():
	if(preview_room):
		room_constructable = false
		shop_constructable = false
		for i in range(room_member.size()):
			room_member[i].room = null
		show_if_possible(false)
		room_member = []
		path_member = []

func has_member():
	return !room_member.empty()

func add_to_path(tile):
	var is_member = path_member.has(tile)
	if(!is_member && !room_member.has(tile)):
		path_member.append(tile)
	return !is_member && !room_member.has(tile)

func constructable():
	return room_kind < 3 && room_constructable || room_kind == 3 && shop_constructable

func construct_room():
	preview_room = false
	var back_up = room_member
	room_member = [] 
	for tile in back_up:
		tile.set_room(self)
	show_if_possible(false)

func check_if_deletable():
	var deletable = true
	for tile in room_member:
		if(tile.state != 1):
			deletable = false
	return deletable

func delete_room():
	group_highlight(0)
	for tile in room_member:
		tile.set_room(null)
	queue_free()
	GV.shop_screen.delete_room(self)

func delete_room_after_fusion():
	queue_free()
	GV.shop_screen.delete_room(self)

func add_enhancing_funiture(funiture):
	if(!enhancing_funiture.has(funiture)):
		enhancing_funiture.append(funiture)
		bonus += 0.2

func remove_enhancing_funiture(funiture):
	if(enhancing_funiture.has(funiture)):
		enhancing_funiture.remove(funiture)
		bonus -= 0.2

func get_bonus():
	if(bonus >= 0.8):
		return 0.8
	else:
		return bonus
