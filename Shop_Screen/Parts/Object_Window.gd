extends Panel

var actual_choise = null
var actual_category = null
var funiture_id_list = []					#Liste die, die Buttons zu der Funiture_id mapt

var actual_tile = null

func _ready():
	get_node("Accept_Button").connect("pressed", self, "accept")
	get_node("Close_Button").connect("pressed", self, "close_button_pressed")

func close_button_pressed():
	if(actual_category == 0):
		GV.shop_screen.hide_possible_rooms()
	elif(actual_category == 1):
		reset_menu()

func set_room_menu():
	var init_button
	for i in range(GV.ROOM_DATA.size()):
		var new_button = Game_Button.new()
		new_button.rect_min_size = Vector2(240,40)
		new_button.set_text(GV.ROOM_DATA[i][0])
		new_button.connect("pressed", self, "chose_room_content", [new_button])
		get_node("Scroll_Box/Object_List").add_child(new_button)
		actual_category = 0
		if(i == 0):
			init_button = new_button
	chose_room_content(init_button)
	show_menue()

func set_funiture_menu(tile):
	funiture_id_list = []
	actual_tile = tile
	var init_button
	for funiture in GV.FUNITURE_DATA:
		if(funiture[3] == tile.room.room_kind):
			funiture_id_list.append(funiture[0])
			var new_button = Game_Button.new()
			new_button.rect_min_size = Vector2(240,40)
			new_button.set_text(funiture[1])
			new_button.connect("pressed", self, "chose_funiture_content", [new_button])
			get_node("Scroll_Box/Object_List").add_child(new_button)
			actual_category = 1
	chose_funiture_content(get_node("Scroll_Box/Object_List").get_children()[0])
	show_menue()

func chose_room_content(button):
	get_node("Object_Name").set_text(GV.ROOM_DATA[button.get_index()][0])
	set_room_picture(button.get_index())
	get_node("Object_Description").set_text(GV.ROOM_DATA[button.get_index()][1])
	actual_choise = button.get_index()

func chose_funiture_content(button):
	get_node("Object_Name").set_text(GV.FUNITURE_DATA[funiture_id_list[button.get_index()]][1])
	set_funiture_picture(funiture_id_list[button.get_index()])
	get_node("Object_Description").set_text(GV.FUNITURE_DATA[funiture_id_list[button.get_index()]][2])
	actual_choise = funiture_id_list[button.get_index()]

func set_room_picture(id):
	match(id):
		0: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.room["Storage"])
		1: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.room["Smithy"])
		2: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.room["Lab"])
		3: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.room["Salesroom"])
	
	get_node("Image_Border/Object_Image").visible = true

func set_funiture_picture(id):
	match(id):
		0: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.funiture["Chest"])
		1: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.funiture["Shelf"])
		2: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.funiture["Smithy_Workstation"])
		3: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.funiture["Prepairforge"])
		4: get_node("Image_Border/Object_Image").set_texture(GV.grafic_library.funiture["Shop_Table"])
	
	get_node("Image_Border/Object_Image").visible = true

func accept():
	if(actual_choise != null):
		if(actual_category == 0):
			GV.shop_screen.show_possible_rooms(actual_choise)
		elif(actual_category == 1):
			GV.shop_screen.show_tiles_for_funiture(actual_tile, actual_choise)
	reset_menu()

func show_menue():
	var viewport_size = get_viewport().get_visible_rect().size
	var x = (viewport_size.x - get_rect().size.x) / 2
	var y = (viewport_size.y - get_rect().size.y) / 2
	
	set_position(Vector2(x,y))
	self.visible = true
	GV.shop_screen.object_window_visible = true

func reset_menu():
	if(self.visible):
		self.visible = false
		GV.shop_screen.object_window_visible = false
		get_node("Object_Name").set_text("")
		get_node("Image_Border/Object_Image").visible = false
		get_node("Object_Description").set_text("")
		actual_choise = null
		actual_category = null
		actual_tile = null
		for child in get_node("Scroll_Box/Object_List").get_children():
			get_node("Scroll_Box/Object_List").remove_child(child)
			child.queue_free()
