extends Node

const KEY:= "nakama"												#Server Key

var _client := Nakama.create_client(KEY)							#Client über den die Verbindung aufgebaut wird
var _session:NakamaSession											#Aktuelle Session
var _socket:NakamaSocket											#Socket Verbindung

var error_message:String

var _actual_world = "1"

#Funktion für den Login
#Prüft zuerst ob ein gültiges Session Token vorhanden ist um sich damit einzuloggen
#und sendet eine Loginanfrage mit e-mail und passwort wenn kein token vorhanden ist
func login_async(email:String, password:String) -> int:
	var token := Session_File_Worker.recover_session_token(email, password)
	if token != "":
		var new_session:NakamaSession = _client.restore_session(token)
		if(new_session.valid && !(new_session.expired)):
			_session = new_session
			yield(Engine.get_main_loop(), "idle_frame")
			return OK
	var new_session:NakamaSession = yield(_client.authenticate_email_async(email, password, null, false), "completed")
	var parse_result := parse_exception(new_session)
	if(parse_result == OK):
		_session = new_session
		Session_File_Worker.write_auth_token(email, _session.token, password)
	return parse_result

#Funktion für die Regestrierung
#Sendet eine Registrierungsanfrage an den Server
func register_async(email:String, password:String) -> int:
	var new_session:NakamaSession = yield(_client.authenticate_email_async(email, password, null, true), "completed")
	var parse_result := parse_exception(new_session)
	if(parse_result == OK):
		_session = new_session
		Session_File_Worker.write_auth_token(email, _session.token, password)
	else:
		error_message = error_message.replace("Username", "Email")
	
	return parse_result

func parse_exception(result: NakamaAsyncResult) -> int:
	if(result.is_exception()):
		var exception: NakamaException = result.get_exception()
		error_message = exception.message
		return exception.status_code
	else:
		return OK

func connect_to_server_async() -> int:
	_socket = Nakama.create_socket_from(_client)
	var result:NakamaAsyncResult = yield(_socket.connect_async(_session), "completed")
	if(!result.is_exception()):
		_socket.connect("connected",self,"connection_established")
		_socket.connect("closed", self, "connection_closed")
		_socket.connect("received_error", self, "connection_error")
		_socket.connect("received_match_state", self, "connection_match_message")
		return OK
	return ERR_CANT_CONNECT

#action wenn Serververbindung geschlossen wird
func connection_closed():
	_socket = null
	GV.main.critical_error("Server Connection Closed")

#action nachdem Serververbiung erstellt wurde
func connection_established():
	print("ServerConnection established")

#action wenn Serververbindung fehlschlägt
func connection_error():
	GV.main.critical_error("Server Connection Error")

func connection_match_message(match_message):
	var data = parse_json(match_message.data)
	match(int(match_message.op_code)):
		1: GV.shop_screen.item_sell_happend(data)

#Der Welt beitreten
func join_world_async() -> int:
	if(!_socket):
		error_message = "Serververbindung nicht gefunden"
		return ERR_UNAVAILABLE
	
	var join_result: NakamaRTAPI.Match = yield(_socket.join_match_async(_actual_world), "completed")
	var parse_result := parse_exception(join_result)
	
	if(parse_result == OK):
		pass
	return parse_result

#Welt_id anfordern
func get_world_id_async():
	var data:NakamaAPI.ApiRpc = yield(_client.rpc_async(_session, "get_world_id", ""),"completed")
	var parsed_result := parse_exception(data)
	if(parsed_result != OK):
		return parsed_result
	
	_actual_world = data.payload
	return OK

#Warendaten anfordern
func get_world_data_async():
	var data:NakamaAPI.ApiRpc = yield(_client.rpc_async(_session, "get_world_data", ""),"completed")
	var parsed_result := parse_exception(data)
	if(parsed_result != OK):
		return null
	return data.payload

#Spielstand anfordern
func get_save_state_async():
	var data:NakamaAPI.ApiRpc = yield(_client.rpc_async(_session, "get_save_state", ""),"completed")
	var parsed_result := parse_exception(data)
	if(parsed_result != OK):
		return null
	return data.payload

func send_action_async(action_id:int, payload:String):
	
	GV.await_server_answer = true
	
	var data:NakamaAPI.ApiRpc
	match(action_id):
		0:	data = yield(_client.rpc_async(_session, "extend_shop", payload),"completed")			#Geschäft erweitern
		1:	data = yield(_client.rpc_async(_session, "construct_wall", payload),"completed")		#Mauerbau
		2:	data = yield(_client.rpc_async(_session, "construct_room", payload),"completed")		#Raumbau
		3:	data = yield(_client.rpc_async(_session, "construct_funiture", payload),"completed")	#Einrichtungsbau
		4:	data = yield(_client.rpc_async(_session, "upgrade_funiture", payload),"completed")		#Aufwerten
		5:	data = yield(_client.rpc_async(_session, "destory_object", payload),"completed")		#Abriss
		6:	data = yield(_client.rpc_async(_session, "hire_worker", payload),"completed")			#Arbeiter einstellen
		7:	data = yield(_client.rpc_async(_session, "fire_worker", payload),"completed")			#Arbeiter entlassen
		8:	data = yield(_client.rpc_async(_session, "start_production", payload),"completed")		#Produktion starten
		10:	data = yield(_client.rpc_async(_session, "offer_for_sale", payload),"completed")		#Ware zum verkauf ausstellen
		11:	data = yield(_client.rpc_async(_session, "update_action", payload),"completed")			#Funiture Aktion abbrechen
		12:	data = yield(_client.rpc_async(_session, "buy_ware", payload),"completed")				#Wahren kaufen
		13:	data = yield(_client.rpc_async(_session, "sell_ware", payload),"completed")				#Wahren verkaufen
		
	var parsed_result := parse_exception(data)
	if(parsed_result != OK):
		return parsed_result
	
	var answer = data.payload.to_int()
	
	match(action_id):
		0:	GV.shop_screen.extend_shop(answer)							#Geschäft erweitern
		1:	GV.shop_screen.construct_wall(answer)						#Mauerbau
		2:	GV.shop_screen.construct_room(answer)						#Raumbau
		3:	GV.shop_screen.construct_funiture(answer)					#Einrichtungsbau
		4:	pass	#Aufwerten
		5:	GV.shop_screen.delete_object(answer)						#Abriss
		6:	GV.shop_screen.commit_hire(answer)							#Arbeiter einstellen
		7:	GV.shop_screen.commit_layoff()								#Arbeiter entlassen
		8:	GV.shop_screen.action_window.start_production(answer)		#Produktion starten
		10:	GV.shop_screen.action_window.start_sell(answer)				#Ware zum verkauf ausstellen
		11:	GV.shop_screen.action_window.commit_update(answer)			#Funiture Aktion abbrechen
		12:	GV.market_screen.commit_buy(answer)							#Wahren kaufen
		13:	GV.market_screen.commit_sell(answer)						#Wahren verkaufen

class Session_File_Worker:
	const AUTH:= "user://auth"

	static func write_auth_token(email:String, token:String, password:String) -> void:
		var file := File.new()
		
		file.open_encrypted_with_pass(AUTH, File.WRITE, password)
		
		file.store_line(email)
		file.store_line(token)
		
		file.close()
		
	static func recover_session_token(email:String, password:String) -> String:
		var file := File.new()
		var error := file.open_encrypted_with_pass(AUTH, File.READ, password)
		
		if error == OK:
			var auth_email := file.get_line()
			var auth_token := file.get_line()
			file.close()
			
			if(auth_email == email):
				return auth_token
		
		return ""








#Servernachricht erhalten
func receive_message():
	#var data = socket.get_peer(1).get_packet()
	#data = data.get_string_from_utf8()
	#GV.main.process_server_message(data)
	pass

#Nachricht an Server senden
func send_message(message):
	#socket.get_peer(1).put_packet(message.to_utf8())
	pass

func send_action(id, data):
	#var message = "4:" + id + ":" + data 
	#socket.get_peer(1).put_packet(message.to_utf8())
	pass

#Serververbindung schließen
func close_connection():
	#socket.disconnect_from_host()
	pass
