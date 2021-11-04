extends Camera2D

const MAX_ZOOM_LEVEL = 1
const MIN_ZOOM_LEVEL = 2.5
const ZOOM_INCREMENT = 0.05

signal moved()
signal zoomed()

var current_zoom_level = 2.0
var drag = false

func _ready():
	set_zoom(Vector2(current_zoom_level, current_zoom_level))

func _input(event):
	if event.is_action_pressed("cam_drag"):
		drag = true
	elif event.is_action_released("cam_drag"):
		drag = false
	elif event.is_action("cam_zoom_in"):
		update_zoom(-ZOOM_INCREMENT, get_local_mouse_position())
	elif event.is_action("cam_zoom_out"):
		update_zoom(ZOOM_INCREMENT, get_local_mouse_position())
	elif event is InputEventMouseMotion && drag:
		
		var offset_change = event.relative
		
		if((offset_change.x <= 0) && (get_offset().x - offset_change.x) >= (4800 - (1200 * current_zoom_level))):
			offset_change.x = -((4800 - (1200 * current_zoom_level)) - get_offset().x)
		if((offset_change.x > 0) && (get_offset().x - offset_change.x) <= 0):
			offset_change.x = get_offset().x
		if((offset_change.y <= 0) && (get_offset().y - offset_change.y) >= (4800 - (900 * current_zoom_level))):
			offset_change.y = -((4800 - (900 * current_zoom_level)) - get_offset().y)
		if((offset_change.y > 0) && (get_offset().y - offset_change.y) <= 0):
			offset_change.y = get_offset().y
			
		set_offset(get_offset() - offset_change)

func update_zoom(incr, zoom_anchor):
	var old_zoom = current_zoom_level
	current_zoom_level += incr
	if current_zoom_level < MAX_ZOOM_LEVEL:
		current_zoom_level = MAX_ZOOM_LEVEL
	elif current_zoom_level > MIN_ZOOM_LEVEL:
		current_zoom_level = MIN_ZOOM_LEVEL
	if old_zoom == current_zoom_level:
		return
   
	var zoom_center = zoom_anchor - get_offset()
	var ratio = 1-current_zoom_level/old_zoom
	set_offset(get_offset() + zoom_center*ratio)
	if(get_offset().x < 0):
		set_offset(Vector2(0, get_offset().y))
	if(get_offset().y < 0):
		set_offset(Vector2(get_offset().x, 0))
	if(get_offset().x >= (4800 - (1200 * current_zoom_level))):
		set_offset(Vector2((4800 - (1200 * current_zoom_level)), get_offset().y))
	if(get_offset().y >= (4800 - (900 * current_zoom_level))):
		set_offset(Vector2(get_offset().x, (4800 - (900 * current_zoom_level))))
	
	set_zoom(Vector2(current_zoom_level, current_zoom_level))
