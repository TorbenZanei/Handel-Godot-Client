extends Node

const Ware_Object = preload("res://Storage_Screen/Parts/Storage_Ware_Object.tscn")

var search_input		#Eingabeleiste für Suchbegriffe
var category_box		#Auswahlbox für die Kategorienauswahl der Suchfunktion
var ware_list			#Liste der momentan vorhandenen Waren

#Namen der Warenkategorien
var category_title = ["Metall: ","Schmiedehalbfabrikat: ","Schmiedeprodukte: ", "Kräuter: ", "Alchemiehalbfabrikat: ", "Alchemieprodukte: "]
var storage_funiture_data = [[null,10],[0,20]]

var storage_funiture = []												#Referencen auf Funitur die Lagerpläte erzeugt
var u_storage_capacity = [0,0]											#[vorhandene Lagerplätze,belegte Lagerplätze] universal Lager
var storage_capacity = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]		#[vorhandene Lagerplätze,belegte Lagerplätze] sortiert nach Kategorie 
var storage = []														#Liste gelagerter Waren [id,menge]
var actual_category = 0													#Kategorie id nach der gerade sortiert wird
var actual_visible_wares												#Liste der Waren die gerade angezeigt werden

func _ready():
	search_input = get_node("Storage_Margin/Storage_VBox/Serch_HBox/Search_Input")
	category_box = get_node("Storage_Margin/Storage_VBox/Serch_HBox/Category_Box")
	ware_list = get_node("Storage_Margin/Storage_VBox/Ware_Scroll/Ware_List")
	
	category_box.get_popup().connect("id_pressed", self, "set_category")
	get_node("Storage_Margin/Storage_VBox/Serch_HBox/Search_Button").connect("pressed", self, "search")


#Funktionen für die Lager UI
#Waren in der Lager UI updaten
func load_storage():
	for ware in ware_list.get_children():
		ware.queue_free()
	var new_ware_info
	var lable = Label.new()
	lable.set_text("Universal Lager: " + String(u_storage_capacity[1]) + "/" + String(u_storage_capacity[0]))
	ware_list.add_child(lable)
	
	for i in range(category_title.size()):
		if((storage_capacity[i][1] != 0 || storage_capacity[i][0] != 0 || check_for_ware_of_category(i))):
			ware_list.add_child(HSeparator.new())
			lable = Label.new()
			lable.set_text(category_title[i] + " " + String(storage_capacity[i][1]) + "/" + String(storage_capacity[i][0]))
			ware_list.add_child(lable)
			for ware in storage:
				if(GV.ware_data[ware[0]][1] == i):
					new_ware_info = Ware_Object.instance()
					ware_list.add_child(new_ware_info)
					new_ware_info.set_ware(GV.ware_data[ware[0]])

#Funktionen für die Waren verwaltung
#Neues Lager eintragen
func add_storage_funiture(funiture):
	storage_funiture.append(funiture)
	var data = storage_funiture_data[funiture.id]
	if(data[0] != null):
		storage_capacity[data[0]][0] += data[1]
	else:
		u_storage_capacity[0] += data[1]
	
	GV.market_screen.update_ware_objects()
	restack_wares()
	load_storage()

#Prüfung ob Lagereinrichtung gelöscht werden kann
func check_if_storage_removable(funiture):
	var deletable = false
	var data = storage_funiture_data[funiture.id]
	
	if(data[0] == null):
		if((u_storage_capacity[0] - data[1]) >= u_storage_capacity[1]):
			deletable = true
	else:
		if((storage_capacity[data[0]][0] - data[1]) >= storage_capacity[data[0]][1]):
			deletable = true
		elif((storage_capacity[data[0]][0] - data[1] + u_storage_capacity[0]) >= storage_capacity[data[0]][1]):
			deletable = true
	
	return deletable

#Lagereinrichtung Löschen
func remove_storage_funiture(funiture):
	var data = storage_funiture_data[funiture.id]
	if(data[0] == null):
		u_storage_capacity[0] -= data[1]
	else:
		if((storage_capacity[data[0]][0] - data[1]) >= storage_capacity[data[0]][1]):
			storage_capacity[data[0]][0] -= data[1]
		else:
			var overflow = storage_capacity[data[0]][1] - (storage_capacity[data[0]][0] - data[1])
			u_storage_capacity[1] += overflow
			storage_capacity[data[0]][1] -= overflow
			storage_capacity[data[0]][0] -= data[1]
	load_storage()

#gibt freien Lagerplatz für eine Waren Kategorie zurück
func get_free_storage(category):
	return (storage_capacity[category][0] - storage_capacity[category][1]) + (u_storage_capacity[0] - u_storage_capacity[1])

#gibt momentan vorhandene Menge einer Ware zurück
func get_actual_amount(ware_id):
	var in_storage = 0
	for ware in storage:
		if(ware[0] == ware_id):
			in_storage = ware[1]
	return in_storage

#prüft ob irgendwelche Waren einer Kategorie auf Lager sind
func check_for_ware_of_category(category_id):
	for ware in storage:
		if(GV.ware_data[ware[0]][1] == category_id):
			return true
	return false

#prüft ob eine bestimmte Menge einer bestimmten Ware noch in das Lager passt
func check_for_space(id, amount):
	var fit = false
	if(storage_capacity[GV.ware_data[id][1]][0] >= storage_capacity[GV.ware_data[id][1]][1] + amount):
		fit = true
	else:
		var space_left = storage_capacity[GV.ware_data[id][1]][0] - storage_capacity[GV.ware_data[id][1]][1]
		if(u_storage_capacity[0] >= (u_storage_capacity[1] + amount - space_left)):
			fit = true
	return fit

#prüft ob die benötigten Waren für einen Auftrag vorhanden sind
func check_for_ressources(wares):
	var on_stock = true				#Flag ob alle benötigten waren auf lager sind
	#Prüfung ob alle benötigten Waren vorhanden sind
	for ware in wares:
		if(get_actual_amount(ware[0]) < ware[1]):
			on_stock = false
	return on_stock

#Eine bestimmte Menge einer bestimmten Ware dem Lager hinzufügen
func add_ware(id, amount):
	var fit = check_for_space(id, amount)
	if(fit):
		var new_ware = true
		for ware in storage:
			if(ware[0] == id):
				ware[1] += amount
				new_ware = false
		if(new_ware):
			storage.append([id, amount])
		
		if(storage_capacity[GV.ware_data[id][1]][0] >= storage_capacity[GV.ware_data[id][1]][1] + amount):
			storage_capacity[GV.ware_data[id][1]][1] += amount
		else:
			var space_left = storage_capacity[GV.ware_data[id][1]][0] - storage_capacity[GV.ware_data[id][1]][1]
			storage_capacity[GV.ware_data[id][1]][1] = storage_capacity[GV.ware_data[id][1]][0]
			u_storage_capacity[1] = u_storage_capacity[1] + amount - space_left
		load_storage()
	return fit

#Eine bestimmte Menge einer bestimmten Ware auß dem Lager entfernen
func remove_ware(ware):
	var actual_ware_data = GV.ware_data[ware[0]]			#Daten der aktuell zu entfernenden ware
	var category_on_stock = 0								#Anzahl der Waren dieser Kategorie auf lager
	
	#Warenverteilung im Lager aktualisieren
	for stock_ware in storage:								#für alle Waren im Lager
		var actual_stock_ware_data = GV.ware_data[stock_ware[0]]	#hole die daten zu aktuell betrachteten ware
		if(actual_stock_ware_data[1] == actual_ware_data[1]):		#prüfe ob ware zu kategorie der zu entfernenden Ware gehört
			category_on_stock += stock_ware[1]						#wenn ja zähle die menge zur kategorie lagermenge hinzu
			
	if(category_on_stock > storage_capacity[actual_ware_data[1]][0]):		#Wenn mehr Waren in der Kategorie als Kategorielagerplatz
		var left = ware[1] - (category_on_stock - storage_capacity[actual_ware_data[1]][0])	
		if(left > 0):
			u_storage_capacity[1] -= (ware[1] - left)
			storage_capacity[actual_ware_data[1]][1] -= left
		else:
			u_storage_capacity[1] -= ware[1]
	else:																	#Wenn weniger oder gleich viel Waren in der Kategorie als Kategorielagerplatz
		storage_capacity[actual_ware_data[1]][1] -= ware[1]					#entferne Waren aus dem Kategorielager
	
	#entferne ware aus dem lager
	for stock_ware in storage:
		if(stock_ware[0] == ware[0]):
			stock_ware[1] -= ware[1]
			if(stock_ware[1] == 0):
				storage.erase(stock_ware)
	load_storage()

#Restack wares into their categorys
func restack_wares():
	for ware in storage:
		
		u_storage_capacity = [u_storage_capacity[0],0]
		storage_capacity = [[storage_capacity[0][0],0],[storage_capacity[1][0],0],[storage_capacity[2][0],0],[storage_capacity[3][0],0],[storage_capacity[4][0],0],[storage_capacity[5][0],0],[storage_capacity[6][0],0]]
		
		if(storage_capacity[GV.ware_data[ware[0]][1]][0] >= storage_capacity[GV.ware_data[ware[0]][1]][1] + ware[1]):
			storage_capacity[GV.ware_data[ware[0]][1]][1] += ware[1]
		else:
			var space_left = storage_capacity[GV.ware_data[ware[0]][1]][0] - storage_capacity[GV.ware_data[ware[0]][1]][1]
			storage_capacity[GV.ware_data[ware[0]][1]][1] = storage_capacity[GV.ware_data[ware[0]][1]][0]
			u_storage_capacity[1] = u_storage_capacity[1] + ware[1] - space_left

#Funktionen für die Such und Sortierfunktionen
#Nach Warenkategori filtern
func set_category():
	pass

#Nach Ware suchen
func search():
	pass
