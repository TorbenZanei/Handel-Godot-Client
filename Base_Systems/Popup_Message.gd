extends Panel

var label
var accept_button

func _ready():
	label = get_node("Popup_Message")
	accept_button = get_node("Accept_Button")
	accept_button.connect("pressed", self, "hide_popup")

func show_popup(message_text):
	label.text = message_text
	
	var viewport_size = get_viewport().get_visible_rect().size
	var x = (viewport_size.x - get_rect().size.x) / 2
	var y = (viewport_size.y - get_rect().size.y) / 2
	
	set_position(Vector2(x,y))
	self.visible = true
	GV.popup_message_visible = true

func hide_popup():
	self.visible = false
	GV.popup_message_visible = false
