
extends Node2D

var spawn
var level = 1

var resource_manager

func _ready():
	resource_manager = get_node("/root/resource_manager")
	resource_manager.connect("amount_changed", self, "resource_amount_changed")
	
	load_game()

func _notification(what):
	if (what==MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		save_game()
		get_tree().quit()

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
	save_game()
	load_level(level)

func next_level():
	level += 1
	resource_manager.fix_amounts()
	save_game()
	load_level(level)
	
func load_game():
	var level = 1
	var stars = 0
	
	var f = File.new()
	var err = f.open_encrypted_with_pass("user://savedata.bin", File.READ, str(OS.get_unique_ID(), "simplistic_top_down"))
	
	if !err:
		level = f.get_64()
		stars = f.get_64()
	
	f.close()
	
	resource_manager.set_resource_amount("stars", stars)
	load_level(level)

func save_game():
	var data = {
		level = level,
		stars = resource_manager.get_resource_amount("stars")
	}
	var f = File.new()
	var err = f.open_encrypted_with_pass("user://savedata.bin", File.WRITE, str(OS.get_unique_ID(), "simplistic_top_down"))
	f.store_64(data.level)
	f.store_64(max(data.stars,0))
	f.close()

func resource_amount_changed(name):
	if name == "stars":
		var stars = resource_manager.get_resource_amount(name)
		
		if(stars < -2):
			resource_manager.set_resource_amount("stars", 0)
			print(resource_manager.get_resource_amount("stars"))
			resource_manager.fix_amounts("stars")
			print(resource_manager.get_resource_amount("stars"))
			
			restart_level()
