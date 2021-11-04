extends TextureRect

const Head_Bar = preload("res://Meta_Elements/Head_Bar.tscn")
const Market_Screen = preload("res://Market_Screen/Market_Screen.tscn")
const Storage_Screen = preload("res://Storage_Screen/Storage_Screen.tscn")
const Conformation_Request = preload("res://Base_Systems/Conformation_Request.tscn")
const Tile_Grid = preload("res://Shop_Screen/Parts/Tile_Grid.gd")

const Room = preload("res://Shop_Screen/Parts/Room.gd")
const Shop_Tile = preload("res://Shop_Screen/Shop_Tile/Shop_Tile.tscn")
const Upgrade_Area = preload("res://Shop_Screen/Parts/Upgrade_Area.gd")

const Object_Window = preload("res://Shop_Screen/Parts/Object_Window.tscn")
const Action_Window = preload("res://Shop_Screen/Parts/Action_Window.tscn")

var construct_mode = 0										#ID was gerade gebaut wird (1:Erweiterung 2:Wand 3:Raum 4:Einrichtung 5:Abriss)

var space = []
var rooms = []
var tile_grid = Tile_Grid.new()

var upgrade_areas = []
var object_window
var action_window
var action_on_request

var object_window_visible = false
var action_window_visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	GV.head_bar = Head_Bar.instance()
	GV.storage_screen = Storage_Screen.instance()
	GV.storage_screen.visible = false
	GV.market_screen = Market_Screen.instance()
	GV.market_screen.visible = false
	object_window = Object_Window.instance()
	action_window = Action_Window.instance()
	GV.conformation_request = Conformation_Request.instance()
	
	get_node("Camera/UI_Layer").add_child(GV.storage_screen)
	get_node("Camera/UI_Layer").add_child(GV.market_screen)
	get_node("Camera/UI_Layer").add_child(object_window)
	get_node("Camera/UI_Layer").add_child(action_window)
	get_node("Camera/UI_Layer").add_child(GV.head_bar)
	get_node("Camera/UI_Layer").add_child(GV.conformation_request)
	
	get_node("Camera/UI_Layer/Upgrade_Button").connect("pressed", self, "show_possible_areas")
	get_node("Camera/UI_Layer/Construct_Wall").connect("pressed", self, "show_tiles_for_wall")
	get_node("Camera/UI_Layer/Construct_Room").connect("pressed", self, "show_construct_room_menue")
	
	get_node("Camera/UI_Layer/Destroy_Button").connect("pressed",self,"show_deletable_object")
	
	get_node("Camera/UI_Layer/Hire_Button").connect("pressed",self,"hire_worker")
	get_node("Camera/UI_Layer/Layoff_Button").connect("pressed",self,"layoff_worker")

#Spielstand laden
func load_savestate(space_data, room_data, tile_data):
	#print(tile_data)
	#Daten darüber welche Teile des Ladens bereits gekauft wurden
	space = space_data
	#Daten über die vorhandenen Räume
	for room in room_data:
		if(typeof(room) == 19):
			rooms.append(Room.new(room[1], room[0]))
	#Daten über die Spielfelder
	var tiles = []
	for i in range(22):
		var row = []
		for l in range(22):
			#Kacheln inizialisieren
			var new_tile = Shop_Tile.instance()
			#Kacheln positionieren
			new_tile.rect_position = Vector2(750 + l * 150, 750 + i * 150)
			new_tile.coordinates = [l ,i]
			
			#Kacheln verlinken
			if(i > 0):
				new_tile.top_tile = tiles[i - 1][l]
				tiles[i - 1][l].bot_tile = new_tile
			if(l > 0):
				new_tile.left_tile = row[l - 1]
				row[l - 1].right_tile = new_tile
			
			#Kacheln an den Baum anhängen und in die Kachelliste eintragen
			get_node("Tile_Area").add_child(new_tile)
			row.append(new_tile)
			#Kacheln mit Raum und Einrichtungsdaten füllen
			var actual_tile_data = tile_data[i][l]
			new_tile.set_state(actual_tile_data[0])
			if(actual_tile_data[0] != 0):
				var actual_room = null
				for room in rooms:
					if(room.room_id == actual_tile_data[1]):
						actual_room = room
				new_tile.set_room(actual_room)
				new_tile.set_funiture(actual_tile_data[2], actual_tile_data[3], actual_tile_data[4], actual_tile_data[5], actual_tile_data[6], actual_tile_data[7])
			#pressed" Signal der Kachel anhängen und der Kachel eine Referenz auf die UI geben
			
			new_tile.connect("pressed",self,"chose_action",[new_tile])
		tiles.append(row)
	tile_grid.set_tiles(tiles)

#Wechsel zwischen den Screens
func switch_screen(screen_id):
	reset_construction_options()
	if(screen_id == 1):
		GV.storage_screen.visible = false
		GV.storage_screen.set_mouse_filter(MOUSE_FILTER_IGNORE)
		GV.market_screen.visible = false
		GV.market_screen.set_mouse_filter(MOUSE_FILTER_IGNORE)
	elif(screen_id == 2):
		GV.storage_screen.load_storage()
		GV.storage_screen.visible = true
		GV.storage_screen.set_mouse_filter(MOUSE_FILTER_STOP)
		GV.market_screen.visible = false
		GV.market_screen.set_mouse_filter(MOUSE_FILTER_IGNORE)
	elif(screen_id == 3):
		GV.storage_screen.visible = false
		GV.storage_screen.set_mouse_filter(MOUSE_FILTER_IGNORE)
		GV.market_screen.visible = true
		GV.market_screen.set_mouse_filter(MOUSE_FILTER_STOP)

#Funktion für ein Auswahl eines Bauvorhabens
func chose_action(source_data):
	if(!action_window_visible && !object_window_visible && !GV.conformation_request_visible && !GV.await_server_answer):	
		if(construct_mode == 0):
			if(source_data.funiture != null):
				source_data.funiture.chose_tile()
			elif(source_data.room != null && source_data.funiture == null):
				reset_construction_options()
				show_construc_funiture_menue(source_data)
		elif(construct_mode == 1):
			if(action_on_request != null):
				action_on_request.selected = true
				GV.conformation_request.request_answer(self,"Geschäft für 2500$ erweitern ?")
		elif(construct_mode == 2):
			action_on_request = source_data
			accept_action(true)
		elif(construct_mode == 3):
			action_on_request.append(source_data)
			accept_action(true)
		elif(construct_mode == 4 && source_data.action_allowed):
			action_on_request.append(source_data)
			accept_action(true)
		elif(construct_mode == 5):
			action_on_request = source_data
			if(action_on_request.state == 1 && action_on_request.room != null):
				accept_action(true)
			elif(action_on_request.state == 2):
				if(action_on_request.room_change_needet):
					GV.conformation_request.request_answer(self,"Räume verbinden ?")
				else:
					accept_action(true)
			elif(action_on_request.state == 3):
				if(action_on_request.funiture.actual_action == 1):
					action_on_request.funiture.chose_tile()
				else:
					accept_action(true)

func accept_action(accepted):
	if(accepted):
		if(construct_mode == 1):
			if(GV.actual_money >= 2500):
				Server_Connection.send_action_async(0, JSON.print(action_on_request.area_position))
			else:
				GV.popup_message.show_popup("Zu wenig Geld")
				hide_possible_area()
		elif(construct_mode == 2):
			if(action_on_request.state <= 2 && action_on_request.action_allowed && GV.actual_money >= 100):
				Server_Connection.send_action_async(1, JSON.print(action_on_request.coordinates))
			else:
				if(!action_on_request.state <= 2 && !action_on_request.action_allowed):
					GV.popup_message.show_popup("Ungültige Baufläche")
				elif(!GV.actual_money >= 100):
					GV.popup_message.show_popup("Zu wenig Geld")
		elif(construct_mode == 3):
			print(action_on_request[0].room_kind)
			if(action_on_request[0].constructable()):
				Server_Connection.send_action_async(2, JSON.print([action_on_request[0].room_kind,action_on_request[1].coordinates]))
		elif(construct_mode == 0):
			if(action_on_request[0].state == 1 && GV.actual_money >= 100):
				Server_Connection.send_action_async(3, JSON.print([action_on_request[1], action_on_request[0].coordinates]))
		elif(construct_mode == 5):
			if(action_on_request.action_allowed):
				Server_Connection.send_action_async(5, JSON.print([action_on_request.delete_id, action_on_request.coordinates]))
	else:
		if(construct_mode == 1):
			hide_possible_area()

#Funktionen für die Vergrößerung des Ladens
func show_possible_areas():
	if(!action_window_visible):
		if(construct_mode == 1):
			hide_possible_area()
		else:
			reset_construction_options()
			for i in range(4):
				for l in range(4):
					if(space[i][l] == 1):
						var new_area = Upgrade_Area.new()
						new_area.position_area(l, i)
						upgrade_areas.append(new_area)
						
			construct_mode = 1
			get_node("Camera/UI_Layer/Upgrade_Button").text = "Abbrechen"

func hide_possible_area():
	
	if(GV.conformation_request_visible):
		GV.conformation_request.hide_request()
	
	for area in upgrade_areas:
		remove_child(area)
		area.aboart_construction()
	upgrade_areas = []
	construct_mode = 0
	action_on_request = null
	get_node("Camera/UI_Layer/Upgrade_Button").text = "Geschäft Erweitern"

func extend_shop(ok):
	if(ok):
		start_construction()
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	hide_possible_area()
	GV.await_server_answer = false

func start_construction():
	#Den Hausteil als im bau markieren
	space[action_on_request.area_position[1]][action_on_request.area_position[0]] = 3
	#Preis von Geld abziehen
	GV.update_money(-2500)
	# bau beenden (bau ist in 2 teile geteilt um später eine bauzeit dazwischen zu setzen)
	finish_construction()

func finish_construction():
	var extantion_x = action_on_request.area_position[0]
	var extatnion_y = action_on_request.area_position[1]
	
	#Den Hausteil als gebaut markieren
	space[extatnion_y][extantion_x] = 2
	#angrenzende Blöcke als bebaubar markieren
	if(extatnion_y < 3 && space[extatnion_y + 1][extantion_x] == 0):
		space[extatnion_y + 1][extantion_x] = 1
	if(extatnion_y > 0 && space[extatnion_y - 1][extantion_x] == 0):
		space[extatnion_y - 1][extantion_x] = 1
	if(extantion_x < 3 && space[extatnion_y][extantion_x + 1] == 0):
		space[extatnion_y][extantion_x + 1] = 1
	if(extantion_x > 0 && space[extatnion_y][extantion_x - 1] == 0):
		space[extatnion_y][extantion_x - 1] = 1
	#Aktiviere die neuen Kacheln
	
	var y = 0
	for row in action_on_request.tile_area:
		var x = 0
		for tile in row:
			if(tile.state == 0):
				if(tile.coordinates[0] == 0 || tile.coordinates[1] == 0 || tile.coordinates[0] == 21 || tile.coordinates[1] == 21):
					tile.set_state(2)
					tile.set_funiture(1, 0, 0, 0, 3, 0)
				elif(y == 0 || x == 0 || y == (action_on_request.tile_area.size() - 1) || x == (row.size() - 1)):
					tile.set_state(2)
					tile.set_funiture(1, 0, 0, 0, 2, 0)
				else:
					tile.set_state(1)
				
				tile.set_room(null)
			x += 1
		y += 1
			
	for row in action_on_request.tile_area:
		for tile in row:
			if(tile.state == 2):
				if(tile.funiture.aditional_data == 2 && !tile.check_if_outer_wall()):
					tile.funiture.aditional_data = 1
				tile.set_funiture_grafics()
	
	hide_possible_area()

#Funktionen für den Mauerbau
func show_tiles_for_wall():
	if(!action_window_visible):
		if(construct_mode == 2):
			reset_construction_options()
		else:
			reset_construction_options()
			construct_mode = 2
			for i in range(22):
				for l in range(22):
					if(tile_grid.grid[i][l].state != 0):
						tile_grid.grid[i][l].set_construct_mode(2)
			get_node("Camera/UI_Layer/Construct_Wall").text = "Abbrechen"

func hide_tiles_for_wall():
	construct_mode = 0
	for i in range(22):
		for l in range(22):
			if(tile_grid.grid[i][l].state != 0):
				tile_grid.grid[i][l].set_construct_mode(0)
	get_node("Camera/UI_Layer/Construct_Wall").text = "Mauerbau"

func construct_wall(ok):
	if(ok):
		action_on_request.start_wall_construction()
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	action_on_request = null
	GV.await_server_answer = false

#Funktionen für den Raumbau
func show_construct_room_menue():
	if(!action_window_visible):
		if(construct_mode == 3):
			reset_construction_options()
		else:
			reset_construction_options()
			construct_mode = 3
			get_node("Camera/UI_Layer/Construct_Room").text = "Abbrechen"
			action_on_request = [Room.new()]
			object_window.set_room_menu()

func show_possible_rooms(room_kind):
	print(room_kind)
	action_on_request[0].room_kind = room_kind
	for i in range(22):
		for l in range(22):
			if(tile_grid.grid[i][l].state > 0):
				tile_grid.grid[i][l].set_construct_mode(3)

func hide_possible_rooms():
	construct_mode = 0
	for i in range(22):
		for l in range(22):
			if(tile_grid.grid[i][l].state > 0):
				tile_grid.grid[i][l].set_construct_mode(0)
	if(action_on_request[0].has_member()):
		action_on_request[0].reset_preview_room()
	action_on_request = null
	get_node("Camera/UI_Layer/Construct_Room").text = "Neuer Raum"
	object_window.reset_menu()

func construct_room(ok):
	if(ok):
		rooms.append(action_on_request[0])
		action_on_request[0].construct_room()
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	hide_possible_rooms()
	GV.await_server_answer = false

func delete_room(room):
	rooms.erase(room)

#Funktionen für den Einrichtungsbau
func show_construc_funiture_menue(tile):
	if(!action_window_visible):
		object_window.set_funiture_menu(tile)

func show_tiles_for_funiture(tile, funiture_id):
	action_on_request = [tile, funiture_id]
	accept_action(true)

func hide_tiles_for_funiture():
	object_window.reset_menu()
	action_on_request = null

func construct_funiture(ok):
	if(ok):
		action_on_request[0].start_funiture_construction(action_on_request[1])
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false

#Funktionen zum abreißen
func show_deletable_object():
	if(!action_window_visible):
		if(construct_mode == 5):
			construct_mode = 0
			stop_delete_object()
		else:
			reset_construction_options()
			construct_mode = 5
			for i in range(22):
				for l in range(22):
					if(tile_grid.grid[i][l].state != 0):
						tile_grid.grid[i][l].set_construct_mode(5)
			
			get_node("Camera/UI_Layer/Destroy_Button").text = "Abbrechen"

func stop_delete_object():
	for i in range(22):
		for l in range(22):
			if(tile_grid.grid[i][l].state != 0):
				tile_grid.grid[i][l].set_construct_mode(0)
	get_node("Camera/UI_Layer/Destroy_Button").text = "Abreißen"

func delete_object(ok):
	if(ok):
		action_on_request.delete_content()
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false

#Abruchs Funktion
func reset_construction_options():
	if(construct_mode == 0):
		hide_tiles_for_funiture()
	if(construct_mode == 1):
		hide_possible_area()
	if(construct_mode == 2):
		hide_tiles_for_wall()
	if(construct_mode == 3):
		hide_possible_rooms()
	if(construct_mode == 5):
		stop_delete_object()

#Funktionen Arbeiter einstellen und endlassen
func hire_worker():
	if(GV.actual_money >= 500):
		Server_Connection.send_action_async(6, "")
	else:
		GV.popup_message.show_popup("Zu wenig Geld")

func commit_hire(ok):
	if(ok):
		GV.update_money(-500)
		GV.update_workforce(1)
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false

func layoff_worker():
	if(GV.actual_workforce[0] > GV.actual_workforce[1]):
		Server_Connection.send_action_async(7, "")
	elif(GV.actual_workforce[0] == 0):
		pass
	else:
		GV.popup_message.show_popup("Alle Arbeiter werden gerade gebraucht")

func commit_layoff(ok):
	if(ok):
		GV.update_workforce(-1)
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false

#Serverseitig gestartete Aktionen
func item_sell_happend(coordinates):
	var tile = tile_grid.get_tile(coordinates[0], coordinates[1])
	tile.funiture.ware_sold()

