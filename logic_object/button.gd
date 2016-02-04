
extends "logic_object.gd"

const player_class = preload("res://player/player.gd")

export var depress_timeout = 1.0
export var only_player = true

var was_pressed = false

func _ready():
	get_node("timer").connect("timeout", self, "set_logic_active", [false])
	if only_player:
		connect("body_enter",self,"_on_body_enter")
		connect("body_exit",self,"_on_body_exit")
	else:
		set_fixed_process(true)

func _fixed_process(delta):
	var pressed = get_overlapping_bodies().size() > 0
	if pressed and !was_pressed:
		get_node("sprite").set_frame(1)
		get_node("timer").stop()
		set_logic_active(true)
	elif !pressed and was_pressed:
		get_node("sprite").set_frame(0)
		var timer = get_node("timer")
		if depress_timeout > 0:
			timer.set_wait_time(depress_timeout)
			timer.start()
	was_pressed = pressed

func _on_body_enter(body):
	if body extends player_class:
		get_node("sprite").set_frame(1)
		set_logic_active(true)

func _on_body_exit(body):
	if body extends player_class:
		get_node("sprite").set_frame(0)
		var timer = get_node("timer")
		get_node("timer").stop()
		if depress_timeout > 0:
			timer.set_wait_time(depress_timeout)
			timer.start()

func logic_changed(new_value):
	if new_value:
		get_node("color").set_frame(1)
	else:
		get_node("color").set_frame(0)

func logic_color_changed(color):
	get_node("color").set_modulate(color)

