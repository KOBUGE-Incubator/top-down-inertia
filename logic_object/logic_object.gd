
extends Node2D

export(String) var key = "default"
export(Color) var color = Color(1, 1, 1, 0)

var game_manager

func _ready():
	game_manager = get_node("../../../")
	game_manager.register_logic(key, color)
	
	game_manager.connect("logic_changed", self, "_logic_changed_filter")
	game_manager.connect("logic_color_changed", self, "_logic_color_changed_filter")
	logic_changed(is_logic_active())
	logic_color_changed(get_logic_color())

func is_logic_active():
	return game_manager.is_logic_active(key)

func set_logic_active(value):
	return game_manager.set_logic_active(key, value)

func get_logic_color():
	color = game_manager.get_logic_color(key)
	return color

func _logic_changed_filter(event_key, value):
	if event_key == key:
		logic_changed(value)

func logic_changed(new_value): # Virtual
	pass

func _logic_color_changed_filter(event_key, color):
	if event_key == key:
		logic_color_changed(color)

func logic_color_changed(new_color): # Virtual
	pass


