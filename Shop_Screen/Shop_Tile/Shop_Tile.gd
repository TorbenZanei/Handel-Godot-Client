extends TextureButton

const Funiture = preload("res://Shop_Screen/Shop_Tile/Funiture.gd")

var coordinates
var timer_label

var top_tile = null
var bot_tile = null
var left_tile = null
var right_tile = null

var state = 0  														#0 Unbenutzbar, 1 Frei, 2 Wand, 3 Bebaut
var funiture = null
var room = null

var construct_mode = 0
var action_allowed = false
var delete_id = 0
var exclude_door = false
var room_change_needet = false
var highlight = 0													#0 kein, 1 blau, 2 rot, 3 grün

# Aufgerufen wenn Node in den Baum eingehängt wird
func _ready():
	var new_atlas = AtlasTexture.new()
	new_atlas.set_atlas(GV.grafic_library.ui["Highlight"])
	get_node("Tile_Highlight").set_texture(new_atlas)
	
	connect("mouse_entered",self,"on_mouse_entered")
	connect("mouse_exited",self,"on_mouse_exit")
	connect("pressed",self,"on_mouse_pressed")
	timer_label = get_node("Tile_Timer")
	
	get_node("Tile_Construct").set_mouse_filter(MOUSE_FILTER_IGNORE)
	get_node("Tile_Highlight").set_mouse_filter(MOUSE_FILTER_IGNORE)

func set_construct_mode(mode):
	construct_mode = mode
	if(mode == 0):
		if(state == 0):
			highlight(0)
		action_allowed = false
	elif(mode == 1 && state == 0):
		highlight(1)

func set_state(new_state):
	state = new_state
	if(state != 0):
		self.visible = true

func set_room(new_room):
	room = new_room
	if(room	!= null):
		room.add_member(self)
	set_room_grafics()

func set_funiture(funiture_id, action, time, outcome, extra, status_flag):
	if(state > 1):
		funiture = Funiture.new(self, funiture_id, action, time, outcome, extra, status_flag)
		GV.global_timer.connect("timeout",funiture,"timer_tic")
		set_funiture_grafics()
		if(state == 3 && funiture_id < 2 && action != 1):
			GV.storage_screen.add_storage_funiture(funiture)

func set_room_grafics():
	if(room != null):
		match(int(room.room_kind)):
			0: set_normal_texture(GV.grafic_library.room["Storage"])
			1: set_normal_texture(GV.grafic_library.room["Smithy"])
			2: set_normal_texture(GV.grafic_library.room["Lab"])
			3: set_normal_texture(GV.grafic_library.room["Salesroom"])
	else:
		set_normal_texture(GV.grafic_library.room["Empty"])
	visible = true

func set_funiture_grafics():
	if(state == 1):
		get_node("Tile_Construct").visible = false
		if(top_tile != null && top_tile.state == 2):
			top_tile.chose_wall_texture()
		if(bot_tile != null && bot_tile.state == 2):
			bot_tile.chose_wall_texture()
		if(left_tile != null && left_tile.state == 2):
			left_tile.chose_wall_texture()
		if(right_tile != null && right_tile.state == 2):
			right_tile.chose_wall_texture()
	elif(state == 2):
		chose_wall_texture()
		if(top_tile != null && top_tile.state == 2):
			top_tile.chose_wall_texture()
		if(bot_tile != null && bot_tile.state == 2):
			bot_tile.chose_wall_texture()
		if(left_tile != null && left_tile.state == 2):
			left_tile.chose_wall_texture()
		if(right_tile != null && right_tile.state == 2):
			right_tile.chose_wall_texture()
	elif(state == 3 && funiture.actual_action != 1):
		if(funiture.actual_action != 0):
			match(int(funiture.id)):
				0: get_node("Tile_Construct").set_texture(GV.grafic_library.activ_funiture["Chest"]) 
				1: get_node("Tile_Construct").set_texture(GV.grafic_library.activ_funiture["Shelf"])
				2: get_node("Tile_Construct").set_texture(GV.grafic_library.activ_funiture["Smithy_Workstation"])
				3: get_node("Tile_Construct").set_texture(GV.grafic_library.activ_funiture["Prepairforge"])
				4: get_node("Tile_Construct").set_texture(GV.grafic_library.activ_funiture["Shop_Table"])
			get_node("Tile_Construct").visible = true
		else:
			match(int(funiture.id)):
				0: get_node("Tile_Construct").set_texture(GV.grafic_library.funiture["Chest"]) 
				1: get_node("Tile_Construct").set_texture(GV.grafic_library.funiture["Shelf"])
				2: get_node("Tile_Construct").set_texture(GV.grafic_library.funiture["Smithy_Workstation"])
				3: get_node("Tile_Construct").set_texture(GV.grafic_library.funiture["Prepairforge"])
				4: get_node("Tile_Construct").set_texture(GV.grafic_library.funiture["Shop_Table"])
			get_node("Tile_Construct").visible = true

func chose_wall_texture():
	var wall_sides = [0,0,0,0]
	if(top_tile != null && top_tile.state == 2):
		wall_sides[0] = 1
	if(bot_tile != null && bot_tile.state == 2):
		wall_sides[1] = 1
	if(left_tile != null && left_tile.state == 2):
		wall_sides[2] = 1
	if(right_tile != null && right_tile.state == 2):
		wall_sides[3] = 1
	match(wall_sides):
		[0,0,0,0]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Pillar"])
		[1,0,0,0]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["End_Down"])
		[0,1,0,0]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["End_Up"])
		[0,0,1,0]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["End_Right"])
		[0,0,0,1]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["End_Left"])
		[1,0,0,1]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Corner_Up"])
		[0,1,0,1]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Corner_Right"])
		[0,1,1,0]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Corner_Down"])
		[1,0,1,0]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Corner_Left"])
		[1,1,1,0]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["T_Left"])
		[0,1,1,1]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["T_Down"])
		[1,0,1,1]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["T_Up"])
		[1,1,0,1]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["T_Right"])
		[1,1,1,1]: get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Cross"])
		[0,0,1,1]: if(funiture.id == 1): get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Horizontal"]);  elif(funiture.id == 2): get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Path_Horizontal"])
		[1,1,0,0]: if(funiture.id == 1): get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Vertical"]);  elif(funiture.id == 2): get_node("Tile_Construct").set_texture(GV.grafic_library.wall["Path_Vertical"])
	get_node("Tile_Construct").visible = true

func check_if_outer_wall():
	return (top_tile.state == 0 || bot_tile.state == 0 || left_tile.state == 0 || right_tile.state == 0)

#Funktionen für den Mauerbau
func check_if_wall_possible():
	action_allowed = !(room != null ||
	!check_if_door_needet()||
	(top_tile.state == 2 && top_tile.funiture.id == 2) ||
	(bot_tile.state == 2 && bot_tile.funiture.id == 2) ||
	(left_tile.state == 2 && left_tile.funiture.id == 2) ||
	(right_tile.state == 2 && right_tile.funiture.id == 2))
	return action_allowed

func check_if_door_possible():
	
	action_allowed = funiture.aditional_data != 2 && (\
	((top_tile != null && top_tile.state == 2 && top_tile.funiture.id == 1) && (bot_tile != null && bot_tile.state == 2 && bot_tile.funiture.id == 1) && \
	(left_tile == null || left_tile.state != 2) && (right_tile == null || right_tile.state != 2)) || \
	((left_tile != null && left_tile.state == 2 && left_tile.funiture.id == 1) && (right_tile != null && right_tile.state == 2 && right_tile.funiture.id == 1) && \
	(top_tile == null || top_tile.state != 2) && (bot_tile == null || bot_tile.state != 2)))
	return action_allowed

func check_if_door_needet():
	exclude_door = true
	action_allowed = true
	var test_room
	for room in GV.shop_screen.rooms:
		if(room != null):
			test_room = GV.shop_screen.Room.new(room.room_kind)
			if(room.room_kind == 3):
				room.room_member[0].check_shop_path(test_room, false)
			else:
				room.room_member[0].check_room_path(test_room, false)
			if(action_allowed):
				action_allowed = test_room.room_kind < 3 && test_room.room_constructable || test_room.room_kind == 3 && test_room.shop_constructable
	exclude_door = false
	
	return action_allowed

func check_room_path(new_room, path):
	if(state == 1 && !exclude_door):
		if(!path && new_room.add_to_path(self)):
			top_tile.check_room_path(new_room, path)
			bot_tile.check_room_path(new_room, path)
			left_tile.check_room_path(new_room, path)
			right_tile.check_room_path(new_room, path)
			
		if(path && new_room.add_to_path(self)):
			top_tile.check_room_path(new_room, path)
			bot_tile.check_room_path(new_room, path)
			left_tile.check_room_path(new_room, path)
			right_tile.check_room_path(new_room, path)
	elif(state == 2 && funiture.id == 2 && new_room.add_to_path(self) && !exclude_door):
		var exit = false
		if(top_tile != null):
			top_tile.check_room_path(new_room, true)
		else:
			exit = true
		if(bot_tile != null):
			bot_tile.check_room_path(new_room, true)
		else:
			exit = true
		if(left_tile != null):
			left_tile.check_room_path(new_room, true)
		else:
			exit = true
		if(right_tile != null):
			right_tile.check_room_path(new_room, true)
		else:
			exit = true
		if(exit):
			new_room.room_constructable = true
	elif(state == 3 && new_room.add_to_path(self)):
		top_tile.check_room_path(new_room, path)
		bot_tile.check_room_path(new_room, path)
		left_tile.check_room_path(new_room, path)
		right_tile.check_room_path(new_room, path)

func check_shop_path(new_room, path):
	if(state == 1):
		if(!path  && new_room.add_to_path(self)):
			top_tile.check_shop_path(new_room, path)
			bot_tile.check_shop_path(new_room, path)
			left_tile.check_shop_path(new_room, path)
			right_tile.check_shop_path(new_room, path)
			
	elif(state == 2 && funiture.id == 2 && new_room.add_to_path(self) && !exclude_door):
		var exit = false
		if(top_tile == null):
			exit = true
		if(bot_tile == null):
			exit = true
		if(left_tile == null):
			exit = true
		if(right_tile == null):
			exit = true
		
		if(exit && !path):
			new_room.shop_constructable = true

func start_wall_construction():
	GV.update_money(-100)
	if(funiture == null):
		state = 2
		funiture = Funiture.new(self, 0, 1, 0, 1, 1, 0)
		funiture.timer_tic()
		GV.global_timer.connect("timeout",funiture,"timer_tic")
	elif(funiture.id == 1):
		funiture.start_action(1, 0, 2, funiture.aditional_data)
		funiture.timer_tic()
	elif(funiture.id == 2):
		funiture.start_action(1, 0, 1, funiture.aditional_data)
		funiture.timer_tic()
	on_mouse_entered()

#Funktion zum abreisen von Mauern
func check_if_wall_deletable():
	delete_id = 1
	action_allowed = true 
	room_change_needet = false
	
	if(funiture.aditional_data == 1):																	#Wand ist Innenwand
		
		action_allowed = GV.shop_screen.tile_grid.check_if_wall_deletable(self)
		if((top_tile.state == 2 && top_tile.funiture.id == 2) || (bot_tile.state == 2 && bot_tile.funiture.id == 2) ||
		(left_tile.state == 2 && left_tile.funiture.id == 2) || (right_tile.state == 2 && right_tile.funiture.id == 2)):
			action_allowed = false 
		
		if(action_allowed):
			if(top_tile.state == 2 && bot_tile.state == 2 && left_tile.state != 2 && right_tile.state != 2):
				if(left_tile.room == null && right_tile.room == null):
					action_allowed = true
				elif(left_tile.room != null && right_tile.room != null && (left_tile.room.room_kind == right_tile.room.room_kind)):
					if(left_tile.room != right_tile.room):
						room_change_needet = true
					action_allowed = true
				elif((left_tile.room == null && right_tile.room != null) || (left_tile.room != null && right_tile.room == null)):
					room_change_needet = true
					action_allowed = true
				else:
					action_allowed = false
			if(top_tile.state != 2 && bot_tile.state != 2 && left_tile.state == 2 && right_tile.state == 2):
				if(top_tile.room == null && bot_tile.room == null):
					action_allowed = true
				elif(top_tile.room != null && bot_tile.room != null && (top_tile.room.room_kind == bot_tile.room.room_kind)):
					if(top_tile.room != bot_tile.room):
						room_change_needet = true
					action_allowed = true
				elif((top_tile.room == null && bot_tile.room != null) || (top_tile.room != null && bot_tile.room == null)):
					room_change_needet = true
					action_allowed = true
				else:
					action_allowed = false
	else:
		action_allowed = false
	
	return action_allowed

func delete_wall():
	if(top_tile.state == 2 && bot_tile.state == 2 && left_tile.state != 2 && right_tile.state != 2):
		if(left_tile.room == null && right_tile.room == null):
			funiture.queue_free()
			funiture == null
			set_state(1)
			set_funiture_grafics()
		elif(left_tile.room != null && right_tile.room != null && (left_tile.room.room_kind == right_tile.room.room_kind)):
			funiture.queue_free()
			funiture == null
			set_state(1)
			set_funiture_grafics()
			if(left_tile.room != right_tile.room):
				var room_backup = left_tile.room
				extend_room(right_tile.room)
				room_backup.delete_room_after_fusion()
			else:
				set_room(left_tile.room)
		elif(left_tile.room == null && right_tile.room != null):
			funiture.queue_free()
			funiture == null
			set_state(1)
			set_funiture_grafics()
			extend_room(right_tile.room)
		elif(left_tile.room != null && right_tile.room == null):
			funiture.queue_free()
			funiture == null
			set_state(1)
			set_funiture_grafics()
			extend_room(left_tile.room)
	elif(top_tile.state != 2 && bot_tile.state != 2 && left_tile.state == 2 && right_tile.state == 2):
		if(top_tile.room == null && bot_tile.room == null):
			funiture.queue_free()
			funiture == null
			set_state(1)
			set_funiture_grafics()
		elif(top_tile.room != null && bot_tile.room != null && (top_tile.room.room_kind == bot_tile.room.room_kind)):
			funiture.queue_free()
			funiture == null
			set_state(1)
			set_funiture_grafics()
			if(top_tile.room != bot_tile.room):
				var room_backup = top_tile.room
				extend_room(bot_tile.room)
				room_backup.delete_room_after_fusion()
			else:
				set_room(top_tile.room)
		elif(top_tile.room == null && bot_tile.room != null):
			funiture.queue_free()
			funiture == null
			set_state(1)
			set_funiture_grafics()
			extend_room(bot_tile.room)
		elif(top_tile.room != null && bot_tile.room == null):
			funiture.queue_free()
			funiture == null
			set_state(1)
			set_funiture_grafics()
			extend_room(top_tile.room)
	else:
		funiture.queue_free()
		funiture == null
		set_state(1)
		set_funiture_grafics()
		if(top_tile.room != null): set_room(top_tile.room)
		elif(bot_tile.room != null): set_room(bot_tile.room)
		elif(left_tile.room != null): set_room(left_tile.room)
		elif(right_tile.room != null): set_room(right_tile.room)
	on_mouse_entered()

func extend_room(room_to_extend):
	if(state == 1):
		if(room_to_extend.add_member(self)):
			set_room(room_to_extend)
			top_tile.extend_room(room_to_extend)
			bot_tile.extend_room(room_to_extend)
			left_tile.extend_room(room_to_extend)
			right_tile.extend_room(room_to_extend)

#Funktionen für den Raumbau
func higlight_possible_room(new_room, path):
	if(state == 1):
		if(!path  && room == null):
			room = new_room
			room.add_member(self)
			top_tile.higlight_possible_room(new_room, path)
			bot_tile.higlight_possible_room(new_room, path)
			left_tile.higlight_possible_room(new_room, path)
			right_tile.higlight_possible_room(new_room, path)
			
		if(path && new_room.add_to_path(self)):
			top_tile.higlight_possible_room(new_room, path)
			bot_tile.higlight_possible_room(new_room, path)
			left_tile.higlight_possible_room(new_room, path)
			right_tile.higlight_possible_room(new_room, path)
	elif(state == 2 && funiture.id == 2 && new_room.add_to_path(self)):
		var exit = false
		if(top_tile != null):
			top_tile.higlight_possible_room(new_room, true)
		else:
			exit = true
		if(bot_tile != null):
			bot_tile.higlight_possible_room(new_room, true)
		else:
			exit = true
		if(left_tile != null):
			left_tile.higlight_possible_room(new_room, true)
		else:
			exit = true
		if(right_tile != null):
			right_tile.higlight_possible_room(new_room, true)
		else:
			exit = true
		
		if(exit):
			new_room.room_constructable = true
	
	elif(state == 3 && new_room.add_to_path(self)):
		top_tile.higlight_possible_room(new_room, path)
		bot_tile.higlight_possible_room(new_room, path)
		left_tile.higlight_possible_room(new_room, path)
		right_tile.higlight_possible_room(new_room, path)

func higlight_possible_shop(new_room, path):
	if(state == 1):
		if(!path  && room == null):
			room = new_room
			room.add_member(self)
			top_tile.higlight_possible_shop(new_room, path)
			bot_tile.higlight_possible_shop(new_room, path)
			left_tile.higlight_possible_shop(new_room, path)
			right_tile.higlight_possible_shop(new_room, path)
			
	elif(state == 2 && funiture.id == 2 && new_room.add_to_path(self)):
		var exit = false
		if(top_tile == null):
			exit = true
		if(bot_tile == null):
			exit = true
		if(left_tile == null):
			exit = true
		if(right_tile == null):
			exit = true
		
		if(exit && !path):
			new_room.shop_constructable = true

#Funktionen für den Einrichtungsbau
func start_funiture_construction(funiture_id):
	GV.update_money(-100)
	if(funiture == null):
		state = 3
		funiture = Funiture.new(self, 0, 1, 10, funiture_id, 0, 0)
		GV.global_timer.connect("timeout",funiture,"timer_tic")
		set_funiture_grafics()

func delete_funiture():
	if(GV.FUNITURE_DATA[funiture.id][4] == 0):
		GV.storage_screen.remove_storage_funiture(funiture)
	elif(GV.FUNITURE_DATA[funiture.id][4] == 2):
		room.remove_enhancing_funiture(funiture)
	funiture.delete_self()
	funiture = null
	state = 1
	set_funiture_grafics()
	set_timer_label(0, false, false)
	on_mouse_entered()

func check_if_funiture_deletable():
	var deletable = false
	if(funiture.actual_action == 0):
		deletable = true
		if(funiture.id < 2):
			deletable = GV.storage_screen.check_if_storage_removable(funiture)
	elif(funiture.actual_action == 1):
		deletable = true
	return deletable

#Bau abbrechen
func abort_construction():
	GV.update_money(50)
	state = 1
	funiture.delete_self()
	funiture = null
	set_timer_label(0, false, false)

func delete_content():
	if(funiture != null && room == null):
		delete_wall()
	elif(funiture == null && room != null):
		room.delete_room()
	elif(funiture != null && room != null):
		delete_funiture()

#0 kein, 1 blau, 2 rot, 3 grün
func highlight(highlight_state, only_color_change = false):
	highlight = highlight_state
	
	if(only_color_change):
		match(highlight):
				1:get_node("Tile_Highlight").get_texture().set_region(Rect2(0,0,75,75))
				2:get_node("Tile_Highlight").get_texture().set_region(Rect2(75,0,75,75))
				3:get_node("Tile_Highlight").get_texture().set_region(Rect2(150,0,75,75))
	else:
		if(highlight > 0):
			get_node("Tile_Highlight").visible = true
			match(highlight):
				1:get_node("Tile_Highlight").get_texture().set_region(Rect2(0,0,75,75))
				2:get_node("Tile_Highlight").get_texture().set_region(Rect2(75,0,75,75))
				3:get_node("Tile_Highlight").get_texture().set_region(Rect2(150,0,75,75))
		else:
			get_node("Tile_Highlight").visible = false

func set_timer_label(time, on_hold, timer_visible):
	time = int(time)
	if(timer_visible || on_hold):
		if(on_hold):
			timer_label.set_text(funiture.reason)
		else:
			var seconds = time % 60
			var minutes = ((time % 3600) - seconds) / 60
			var hours = (time - (time % 3600)) / 3600;
			
			if(seconds < 10):
				seconds = "0" + String(seconds)
			if(minutes < 10):
				minutes = "0" + String(minutes)
			if(hours < 10):
				hours = "0" + String(hours)
			
			var time_string = String(hours) + ":" + String(minutes) + ":" + String(seconds);
			timer_label.set_text(time_string)
		if(!timer_label.visible):
			timer_label.visible = true
	else:
		timer_label.visible = false

#Signal verwaltungs Funktionen
func on_mouse_entered():
	action_allowed = false
	delete_id = 0
	room_change_needet = false
	if(state == 0):
		if(construct_mode == 1):
			pass
	elif(state == 1):
		highlight(1)
		if(construct_mode == 0):
			if(room != null && funiture == null):
				highlight(3)
		elif(construct_mode == 2):
			if(check_if_wall_possible()):
				highlight(3)
			else:
				highlight(2)
		elif(construct_mode == 3):
			if(GV.shop_screen.action_on_request[0].has_member()):
				GV.shop_screen.action_on_request[0].reset_preview_room()
			if(room == null || room == GV.shop_screen.action_on_request[0]):
				if(GV.shop_screen.action_on_request[0].room_kind < 3):
					higlight_possible_room(GV.shop_screen.action_on_request[0], false)
					GV.shop_screen.tile_grid.check_room_wall(room)
					room.show_if_possible(true)
				elif(GV.shop_screen.action_on_request[0].room_kind == 3):
					higlight_possible_shop(GV.shop_screen.action_on_request[0], false)
					GV.shop_screen.tile_grid.check_room_wall(room)
					room.show_if_possible(true)
			elif(room != GV.shop_screen.action_on_request[0]):
				highlight(2)
		elif(construct_mode == 5):
			if(room == null):
				highlight(1)
			elif(room.check_if_deletable()):
				action_allowed = true
				delete_id = 2
				room.group_highlight(3)
			else:
				highlight(2)
		else:
			highlight(1)
	elif(state == 2):
		if(construct_mode == 2):
			if(funiture.id == 1):
				if(check_if_door_possible()):
					highlight(3)
				else:
					highlight(2)
			elif(funiture.id == 2):
				if(check_if_door_needet()):
					highlight(3)
				else:
					highlight(2)
		elif(construct_mode == 3):
			if(GV.shop_screen.action_on_request[0].has_member()):
				GV.shop_screen.action_on_request[0].reset_preview_room()
			highlight(2)
		elif(construct_mode == 4):
			highlight(2)
		elif(construct_mode == 5):
			if(check_if_wall_deletable()):
				highlight(3)
			else:
				highlight(2)
		else:
			highlight(1)
	elif(state == 3):
		if(construct_mode == 2):
			highlight(2)
		elif(construct_mode == 3):
			highlight(2)
		elif(construct_mode == 4):
			highlight(2)
		elif(construct_mode == 5):
			if(check_if_funiture_deletable()):
				action_allowed = true
				delete_id = 3
				highlight(3)
			else:
				highlight(2)
		else:
			highlight(1)
		pass

func on_mouse_exit():
	if(state == 0):
		pass
	elif(state == 1):
		if(construct_mode == 3):
			if(room != GV.shop_screen.action_on_request[0]):
				highlight(0)
		elif(construct_mode == 4):
			if(room != null):
				room.group_highlight(0)
			else: 
				highlight(0)
		else:
			highlight(0)
	else:
		highlight(0)

func on_mouse_pressed():
	
	if(state == 3 && funiture != null && funiture.actual_action != 1):
		funiture.play_soundclip() 
	elif(state != 0):
		GV.sound_player.play_effect(GV.sound_player.BUTTON_CLICK)

func set_effect(state):
	if(state):
		get_node("Tile_Effect").visible = true
	else:
		get_node("Tile_Effect").visible = false
