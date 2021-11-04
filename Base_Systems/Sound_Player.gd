extends Node

const BUTTON_HOVER = 0
const BUTTON_CLICK = 1
const COIN_SOUND = 2
const CHEST = 3
const SHELF = 4
const SMITHY_WORKPLACE = 5

var sound_effects = AudioStreamPlayer.new()

var volume = -10.0

func _ready():
	add_child(sound_effects)
	sound_effects.volume_db = volume

#Soundeffect auf dem default stream (kein paralleles abspiellen)
#wenn ein zweiter Effect aufgerufen wird wird der laufende abgebrochen
func play_effect(effect_id):
	match(effect_id):
		0: sound_effects.stream = load("res://Base_Systems/Sound_Clips/button_hover.wav")
		1: sound_effects.stream = load("res://Base_Systems/Sound_Clips/button_click.wav")
		2: sound_effects.stream = load("res://Base_Systems/Sound_Clips/coin_sound.wav")
		3: sound_effects.stream = load("res://Base_Systems/Sound_Clips/select_chest_sound.wav")
		4: sound_effects.stream = load("res://Base_Systems/Sound_Clips/select_shelf_sound.wav")
		5: sound_effects.stream = load("res://Base_Systems/Sound_Clips/select_smithy_sound.wav")
	
	sound_effects.play()

#Soundeffect auf einen eigenen Stream setzen (für parallel laufende Soundeffecte)
func play_effect_os(effect_id):
	print("test player")
	var one_time_stream =  AudioStreamPlayer.new()
	one_time_stream.volume_db = volume
	add_child(one_time_stream)
	
	match(effect_id):
		0: one_time_stream.stream = load("res://Base_Systems/Sound_Clips/button_hover.wav")
		1: one_time_stream.stream = load("res://Base_Systems/Sound_Clips/button_click.wav")
		2: one_time_stream.stream = load("res://Base_Systems/Sound_Clips/coin_sound.wav")
		3: one_time_stream.stream = load("res://Base_Systems/Sound_Clips/select_chest_sound.wav")
		4: one_time_stream.stream = load("res://Base_Systems/Sound_Clips/select_shelf_sound.wav")
		5: one_time_stream.stream = load("res://Base_Systems/Sound_Clips/select_smithy_sound.wav")
	

	one_time_stream.play()
	
	yield(one_time_stream,"finished")
	one_time_stream.queue_free()
