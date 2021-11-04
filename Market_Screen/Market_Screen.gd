extends Panel

const Ware_Object = preload("res://Market_Screen/Parts/Market_Ware_Object.tscn")

var category_list
var ware_list

var actual_categorie
var actual_wares = []

var buy_sell_mode = 0

var actual_transaction

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Market_UI/Action_Container/Action_Button_List/Buy_Button").connect("pressed", self, "set_to_buy")
	get_node("Market_UI/Action_Container/Action_Button_List/Sell_Button").connect("pressed", self, "set_to_sell")
	
	category_list = get_node("Market_UI/Category_Scroll/Category_List")
	ware_list = get_node("Market_UI/Ware_Scroll/Ware_List")
	for category in category_list.get_children():
		category.connect("pressed", self, "chose_category", [category])

func set_to_buy():
	for ware in ware_list.get_children():
		ware.set_to_buy()
	buy_sell_mode = 0
	update_ware_objects()

func set_to_sell():
	for ware in ware_list.get_children():
		ware.set_to_sell()
	buy_sell_mode = 1
	update_ware_objects()

func reload_category(id):
	for ware in ware_list.get_children():
		ware.queue_free()
	
	actual_categorie = id
	var ware_data = GV.ware_data
	actual_wares = []
	for ware in ware_data:
		if(ware[1] == actual_categorie):
			actual_wares.append(ware)
	
	var new_ware_info
	for ware in actual_wares:
		if(ware[1] == actual_categorie):
			new_ware_info = Ware_Object.instance()
			ware_list.add_child(new_ware_info)
			new_ware_info.set_ware(ware, buy_sell_mode)

func update_ware_objects():
	for ware in ware_list.get_children():
		ware.update()

func chose_category(source):
	reload_category(source.get_index())

func buy_sell_ware(source):
	if(source.actual_amount > 0):
		if(buy_sell_mode):
			actual_transaction = [source.actual_ware, source.actual_amount]
			Server_Connection.send_action_async(13, JSON.print([source.actual_ware[0], source.actual_amount]))
		else:
			if(source.actual_ware[6] * source.actual_amount <= GV.actual_money):
				actual_transaction = [source.actual_ware, source.actual_amount]
				Server_Connection.send_action_async(12, JSON.print([source.actual_ware[0], source.actual_amount]))
		
		for ware in ware_list.get_children():
			ware.actual_amount = 0
			ware.amount_edit.set_text(String(ware.actual_amount))
			ware.pack_price_label.set_text("0")

func commit_buy(ok):
	if(ok):
		GV.storage_screen.add_ware(actual_transaction[0][0], actual_transaction[1])
		GV.update_money(-(actual_transaction[0][6] * actual_transaction[1]))
		update_ware_objects()
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false

func commit_sell(ok):
	if(ok):
		GV.storage_screen.remove_ware([actual_transaction[0][0], actual_transaction[1]])
		GV.update_money((actual_transaction[0][6] * actual_transaction[1] * 0.7))
		update_ware_objects()
	else:
		GV.main.critical_error("Fehler bei Serverabgleich")
	GV.await_server_answer = false
