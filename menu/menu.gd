
extends HBoxContainer

var controls_shown = false
var rebound_action = null

var animation_player
var save_manager

func _ready():
	animation_player = get_node("animation_player")
	save_manager = get_node("/root/save_manager")
	
	for action in get_node("controls").get_children():
		var action_name = action.get_name()
		if save_manager.actions.has(action_name):
			var button = action.get_node("action")
			button.set_text(OS.get_scancode_string(save_manager.actions[action_name]))
			button.connect("toggled", self, "toggle_action_assign", [action])
		elif save_manager.config.has(action_name):
			if action extends BaseButton and action.is_toggle_mode():
				action.connect("toggled", self, "change_config", [action_name])
				action.set_pressed(save_manager.config[action_name])
				
	
	get_node("main/content/play").connect("pressed", self, "play")
	get_node("main/content/controls").connect("pressed", self, "toggle_controls")

func _input(event):
	if event.type == InputEvent.KEY:
		set_process_input(false)
		if !event.is_action("ui_cancel") and rebound_action != null:
			action_assign(rebound_action, event)

func change_config(value, option):
	save_manager.config[option] = value

func toggle_action_assign(toggle, action):
	var button = action.get_node("action")
	if toggle:
		for other_action in get_node("controls").get_children():
			if save_manager.actions.has(other_action.get_name()) and other_action.get_name() != action.get_name():
				var other_button = other_action.get_node("action")
				if other_button.is_pressed():
					other_button.set_text(OS.get_scancode_string(save_manager.actions[other_action.get_name()]))
					other_button.set_pressed(false)
		
		button.set_pressed(true)
		button.set_text("Press key")
		
		rebound_action = action
		set_process_input(true)
	else:
		button.set_text(OS.get_scancode_string(save_manager.actions[action.get_name()]))

func action_assign(action, event):
	var button = action.get_node("action")
	var action_name = action.get_name()
	
	save_manager.rebind_action(action_name, event.scancode)
	
	button.set_pressed(false)
	button.set_text(OS.get_scancode_string(save_manager.actions[action_name]))

func play():
	get_tree().change_scene_to(preload("res://main/game.tscn"))

func toggle_controls():
	if controls_shown:
		animation_player.play("controls_exit")
	else:
		animation_player.play("controls_enter")
	controls_shown = !controls_shown
