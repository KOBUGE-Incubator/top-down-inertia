
extends Node

const action_list = [
	'move_up', 'move_left', 'move_right', 'move_down',
	'shoot_up', 'shoot_left', 'shoot_right', 'shoot_down'
]

var level = 1
var actions = {}
var default_actions = {}

var config = {}
const default_config = {
	shoot_with_mouse = false
}

var resource_manager

func _ready():
	resource_manager = get_node("/root/resource_manager")
	
	for action in action_list:
		if !action.begins_with("ui_"):
			for trigger in InputMap.get_action_list(action):
				default_actions[action] = -1
				if trigger.type == InputEvent.KEY:
					default_actions[action] = trigger.scancode
					break
	print(default_actions)
	
	load_game()

func _notification(what):
	if (what==MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		save_game()
		get_tree().quit()

func load_game():
	level = 1
	var stars = 0
	actions = default_actions
	config = default_config
	
	var f = File.new()
	var err = f.open_encrypted_with_pass("user://savedata.bin", File.READ, str(OS.get_unique_ID(), "simplistic_top_down"))
	
	if !err:
		level = f.get_64()
		stars = f.get_64()
		actions = f.get_var()
		config = f.get_var()
	
	if actions == null:
		actions = default_actions
	else:
		for action in default_actions:
			if !actions.has(action) or actions[action] == -1:
				actions[action] = default_actions[action]
	for action in actions:
		rebind_action(action, actions[action])
	
	if config == null:
		config = default_config
	else:
		for option in default_config:
			if !config.has(option):
				config[option] = default_config[option]
	
	f.close()
	
	resource_manager.set_resource_amount("stars", stars)

func save_game():
	var stars = resource_manager.get_resource_amount("stars")
	var f = File.new()
	var err = f.open_encrypted_with_pass("user://savedata.bin", File.WRITE, str(OS.get_unique_ID(), "simplistic_top_down"))
	f.store_64(level)
	f.store_64(max(stars,0))
	f.store_var(actions)
	f.store_var(config)
	f.close()

func rebind_action(action_name, scancode):
	actions[action_name] = scancode
	
	var event = InputEvent()
	event.type = InputEvent.KEY
	event.scancode = scancode
	
	for old_event in InputMap.get_action_list(action_name):
		InputMap.action_erase_event(action_name, old_event)
	
	if InputMap.get_action_list(action_name).size() > 0:
		InputMap.erase_action(action_name)
		InputMap.add_action(action_name)
	
	InputMap.action_add_event(action_name, event)


