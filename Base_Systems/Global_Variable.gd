extends Node

const Sound_Player = preload("res://Base_Systems/Sound_Player.gd")
const Grafic_Library = preload("res://Base_Systems/Grafic_Library.gd")

const ROOM_DATA = [["Lager", "Ein Lager"], ["Schmiede", "Eine Schmiede"], ["Alchemie Labor", "Ein Alchemielabor"], ["Laden", "Ein Verkaufsladen"]]
					#

const FUNITURE_DATA = [[0, "Kiste", "Eine Kiste", 0, 0],
					   [1, "Regal", "Ein Regal", 0, 0], 
					   [2, "Schmiedearbeitsplatz", "Werkbank, Amboss, Esse und Werkzeuge. Die Grundausrüstung für Schmiedearbeiten", 1, 1, [2,3,4]],
					   [3, "Vorbereitungsesse", "Eine großer Esse um Werkstücke vor zu wärmen um sie bei bedarf sofort verwenden zu können ", 1, 2],
					   [4, "Ausstelltische", "Tische um Waren zum verkauf auszustellen", 3, 3]]

var main									#Referenz Main Root

var head_bar								#Referenz Head_Bar
var login_screen							#Referenz Login_Screen
var shop_screen								#Referenz Shop_Screen
var storage_screen							#Referenz Storage_Screen
var market_screen							#Referenz Market_Screen

var global_timer							#Referenz Game Timer
var sound_player							#Referenz Sound Player
var grafic_library							#Referenz Sprite Bibliothek
var conformation_request
var popup_message

var ware_data

var actual_money = 0
var actual_workforce = [0,0]

var conformation_request_visible = false
var popup_message_visible = false

var await_server_answer = false 			#Flag dass eine Serveranfrage gestellt wurde
											#auf deren Antwort gewartet wird

func _ready():
	global_timer = Timer.new()
	global_timer.wait_time = 1
	global_timer.connect("timeout", self, "timer_tic")
	sound_player = Sound_Player.new()
	grafic_library = Grafic_Library.new()

#Startet den Timer des Clienten
func start_time():
	global_timer.start()

#Gibt die Aktuelle Uhrzeit als Formatieren String zurück in Form von 00:00
func get_actual_time():
	var hour = OS.get_time()["hour"]
	if(hour < 10):
		hour = "0" + String(hour)
	else:
		hour = String(hour)
	
	var minute = OS.get_time()["minute"]
	if(minute < 10):
		minute = "0" + String(minute)
	else:
		minute = String(minute)
	
	return hour + ":" + minute

#Konvertiert eine Zeitspanne in Secunden in einen Formatierten String in Form von 00:00:00
func convert_sec_to_string(time_in_sec):
	var seconds = time_in_sec % 60
	var minutes = ((time_in_sec % 3600) - seconds) / 60
	var hours = (time_in_sec - (time_in_sec % 3600)) / 3600;
	
	if(seconds < 10):
		seconds = "0" + String(seconds)
	if(minutes < 10):
		minutes = "0" + String(minutes)
	if(hours < 10):
		hours = "0" + String(hours)
			
	return String(hours) + ":" + String(minutes) + ":" + String(seconds)

#Secunden Tic des Globalen Timers
func timer_tic():
	pass

func update_money(value):
	actual_money += value
	head_bar.update_actual_money()

func update_workforce(value):
	actual_workforce[0] += value
	head_bar.update_actual_workforce()

func update_activ_workforce(value):
	actual_workforce[1] += value
	head_bar.update_actual_workforce()
