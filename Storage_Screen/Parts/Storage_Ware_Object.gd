extends Panel

#Einzelteile der Scene
var name_label
var image
var description
var ware_id_label
var ware_category_label
var ware_price_label
var storage_amount_lable

#Momentan Angezeigte Ware und Ausgewählte Menge
var actual_ware
var actual_amount = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	name_label = get_node("Background_Margin/HBox_Split/Margin_Left_Part/VBox_Left_part/Name")
	image = get_node("Background_Margin/HBox_Split/Margin_Left_Part/VBox_Left_part/Picture_Border/Picture")
	description = get_node("Background_Margin/HBox_Split/Margin_Description/Description")
	ware_id_label = get_node("Background_Margin/HBox_Split/Margin_Amount/VBox_Amount/Label_Ware_Id")
	ware_category_label = get_node("Background_Margin/HBox_Split/Margin_Amount/VBox_Amount/Label_Ware_Category")
	ware_price_label = get_node("Background_Margin/HBox_Split/Margin_Amount/VBox_Amount/Label_Ware_Price")
	storage_amount_lable = get_node("Background_Margin/HBox_Split/Margin_Amount/VBox_Amount/Label_Storage_Amount")

func set_ware(ware):
	actual_ware = ware
	name_label.set_text(ware[2])
	description.set_text(ware[3])
	set_picture(int(actual_ware[0]))
	ware_id_label.set_text("Waren Nummer: " + String(actual_ware[0]))
	ware_category_label.set_text("Waren Kategorie: " + String(actual_ware[1]))
	ware_price_label.set_text("Marktpreis: " + String(actual_ware[6]))
	storage_amount_lable.set_text("Lagerbestand: " + String(GV.storage_screen.get_actual_amount(actual_ware[0])))

func set_picture(id):
	match(id):
		0: image.set_texture(GV.grafic_library.ware["Copper"])
		1: image.set_texture(GV.grafic_library.ware["Iron"])
		2: image.set_texture(GV.grafic_library.ware["Chainlink"])
		3: image.set_texture(GV.grafic_library.ware["Ironhelmet"])
		4: image.set_texture(GV.grafic_library.ware["Chainmail"])
