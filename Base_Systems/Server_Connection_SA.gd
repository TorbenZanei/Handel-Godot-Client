extends Node

#Veränderte Connection Klasse um den Clienten ohne server zu benutzen zu können
#Speichern ist ohne Server nicht möglich (vieleicht später über cookies)

func send_message(message):
	message = message.rsplit(":")
	match(int(message[0])):
		0: GV.main.succesfull_login()
		1: pass
		2: GV.main.receive_ware_data_update(ware_data())
		3: GV.main.receive_save_data(default_save_data())

func ware_data():
	var ware_data
	ware_data = '['
	
	ware_data += '[0,0,"Kupfer","Ein Kupferbarren",[],0,20],'
	ware_data += '[1,0,"Eisen","Ein Eisenbarren",[],0,30],'
	ware_data += '[2,1,"Kettenglieder","Ringglieder für Kettenrüstungen",[[1,2]],5,70],'
	ware_data += '[3,2,"Eisenhelm","Ein einfacher Eisenhelm",[[0,1],[1,3]],10,100],'
	ware_data += '[4,2,"Kettenhemd","Ein Einfaches Kettenhemd",[[2,3]],15,150]'
	
	ware_data += ']'
	
	return ware_data

func default_save_data():
	var new_safe_data = '[500000,0,[[2,1,0,0],[1,0,0,0],[0,0,0,0],[0,0,0,0]],[1],['
	new_safe_data += '[[2,0,1,0,0,0,3],[2,0,1,0,0,0,3],[2,0,1,0,0,0,3],[2,0,1,0,0,0,3],[2,0,1,0,0,0,3],[2,0,1,0,0,0,3],[2,0,1,0,0,0,3],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]'
	for i in range(5):
		new_safe_data += ',[[2,0,1,0,0,0,3],[1,0,0,0,0,0,0],[1,0,0,0,0,0,0],[1,0,0,0,0,0,0],[1,0,0,0,0,0,0],[1,0,0,0,0,0,0],[2,0,1,0,0,0,2],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]'
	new_safe_data += ',[[2,0,1,0,0,0,3],[2,0,1,0,0,0,2],[2,0,1,0,0,0,2],[2,0,1,0,0,0,2],[2,0,1,0,0,0,2],[2,0,1,0,0,0,2],[2,0,1,0,0,0,2],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]'
	for i in range(15):
		new_safe_data += ',[[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0],[0]]'
	new_safe_data += '],[]]'
	
	return new_safe_data

func send_action(id, data):
	GV.main.process_server_message("3:[" + String(id) + ",1]")
