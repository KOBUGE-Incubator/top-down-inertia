
extends VBoxContainer

export(NodePath) var player_path

var health_full
var stars_label

var player
var resource_manager

var health_full_initial_region

func _ready():
	health_full = get_node("health/full")
	stars_label = get_node("stars/label")
	
	resource_manager = get_node("/root/resource_manager")
	player = get_node(player_path)
	
	health_full_initial_region = health_full.get_region_rect()
	
	player.connect("health_changed", self, "update_values")
	resource_manager.connect("amount_changed", self, "update_values")

func update_values():
	var health_percent = player.health / player.start_health
	health_full.set_region_rect(Rect2(health_full_initial_region.pos, health_full_initial_region.size * Vector2(health_percent,1)))
	
	var stars = resource_manager.get_resource_amount("stars")
	stars_label.set_text(str("x ", stars))
