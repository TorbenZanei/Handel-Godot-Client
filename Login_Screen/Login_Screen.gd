extends Panel

func _ready():
	get_node("Register_Button").connect("pressed", self, "register")
	get_node("Login_Button").connect("pressed", self, "login")

#Log_In Anfrage sende
func login():
	var result = yield(Server_Connection.login_async(get_node("Login_Name").text, get_node("Login_Password").text), "completed")
	if(result == OK):
		GV.main.succesfull_login()
	else:
		set_feedback_note(result)

#Registrierungs Anfrage senden
func register():
	var result = yield(Server_Connection.register_async(get_node("Login_Name").text, get_node("Login_Password").text), "completed")
	if(result == OK):
		GV.main.succesfull_login()
	else:
		set_feedback_note(result)

#Feedback Nachricht anzeigen
func set_feedback_note(text):
	 get_node("Feedback_Note").text = Server_Connection.error_message
