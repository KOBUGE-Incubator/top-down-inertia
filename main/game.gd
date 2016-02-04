
extends Node2D

signal logic_changed(key, value)
signal logic_color_changed(key, color)

var spawn
var level = 1

var resource_manager
var save_manager

var logic_active = {}
var logic_colors = {}

func _ready():
	resource_manager = get_node("/root/resource_manager")
	save_manager = get_node("/root/save_manager")
	
	resource_manager.connect("amount_changed", self, "resource_amount_changed")
	
	load_level(save_manager.level)

func register_logic(key, color):
	if !logic_active.has(key):
		logic_active[key] = 0
		emit_signal("logic_changed", key, false)
	if color.a > 0.1 and !logic_colors.has(key):
		logic_colors[key] = color
		emit_signal("logic_color_changed", key, color)

func is_logic_active(key):
	if logic_active.has(key):
		return logic_active[key] > 0
	else:
		return false

func get_logic_color(key):
	if logic_colors.has(key):
		return logic_colors[key]
	else:
		return Color(0, 0, 0, 1)

func set_logic_active(key, value):
	value = bool(value)
	
	var was_active = is_logic_active(key)
	
	if !logic_active.has(key):
		logic_active[key] = 0
	
	if value:
		logic_active[key] += 1
	elif logic_active[key] > 0:
		logic_active[key] -= 1
		
	var is_active = is_logic_active(key)
	
	if was_active != is_active:
		emit_signal("logic_changed", key, is_active)

func load_level(var l):
	var holder = get_node("level_holder")
	var player = get_node("player")
	player.tilemap = null
	
	for i in range(holder.get_child_count()):
		holder.get_child(i).queue_free()
	
	var level = load(str("res://levels/", "level_test", ".tscn")).instance()
	holder.add_child(level)
	
	logic_active = {}
	logic_colors = {}
	
	player.tilemap = level
	player.set_checkpoint(level.get_node("spawn"))
	player.restart_from_checkpoint()

func restart_level():
	resource_manager.restart_amounts()
	save_manager.save_game()
	load_level(save_manager.level)

func next_level():
	save_manager.level += 1
	resource_manager.fix_amounts()
	save_manager.save_game()
	load_level(save_manager.level)

func resource_amount_changed(name):
	if name == "stars":
		var stars = resource_manager.get_resource_amount(name)
		
		if(stars < -2):
			resource_manager.set_resource_amount("stars", 0)
			print(resource_manager.get_resource_amount("stars"))
			resource_manager.fix_amounts("stars")
			print(resource_manager.get_resource_amount("stars"))
			
			restart_level()
