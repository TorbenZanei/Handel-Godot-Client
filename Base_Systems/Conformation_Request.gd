extends Panel

var source_last_request
var label

func _ready():
	label = get_node("Request_Text")
	
	get_node("Accept_Button").connect("pressed",self,"send_answer",[true])
	get_node("Abort_Button").connect("pressed",self,"send_answer",[false])

func request_answer(source, text):
	source_last_request = source
	label.set_text(text)
	
	var viewport_size = get_viewport().get_visible_rect().size
	var x = (viewport_size.x - get_rect().size.x) / 2
	var y = (viewport_size.y - get_rect().size.y) / 2
	
	set_position(Vector2(x,y))
	self.visible = true
	GV.conformation_request_visible = true

func send_answer(answer):
	source_last_request.accept_action(answer)
	hide_request()

func hide_request():
	self.visible = false;
	GV.conformation_request_visible = false
