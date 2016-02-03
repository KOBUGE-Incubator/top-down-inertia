
extends Node2D

var spawn
var level = 1

var resource_manager
var save_manager

func _ready():
	resource_manager = get_node("/root/resource_manager")
	save_manager = get_node("/root/save_manager")
	
	resource_manager.connect("amount_changed", self, "resource_amount_changed")
	
	load_level(save_manager.level)

func load_level(var l):
	var holder = get_node("level_holder")
	var player = get_node("player")
	player.tilemap = null
	
	for i in range(holder.get_child_count()):
		holder.get_child(i).queue_free()
	
	var level = load(str("res://levels/", "level_test", ".tscn")).instance()
	holder.add_child(level)
	
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
