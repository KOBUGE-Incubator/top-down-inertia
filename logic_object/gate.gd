
extends "logic_object.gd"

const player_class = preload("res://player/player.gd")

var layer_mask
var collision_mask

func logic_changed(new_value):
	if layer_mask == null:
		layer_mask = get_layer_mask()
		collision_mask = get_collision_mask()
		
	if new_value:
		set_layer_mask(0)
		set_collision_mask(0)
		get_node("color").set_frame(1)
		get_node("sprite").set_frame(1)
	else:
		set_layer_mask(layer_mask)
		set_collision_mask(collision_mask)
		get_node("color").set_frame(0)
		get_node("sprite").set_frame(0)

func logic_color_changed(color):
	get_node("color").set_modulate(color)

