
extends RigidBody2D

signal health_changed()

export var move_speed = 40.0
export var bullet_offset = 16.0
export var start_health = 10.0
export var auto_heal_time = 0.5
export(PackedScene) var bullet_scene

var health = 0
var auto_heal = -1
var mouse_pos = Vector2(0,1)
var last_shot = -1000
var time = 0

var save = true
var can_move = false
var after_animation = ""

var fullscreen = false

var tilemap
var last_checkpoint
var animation_player
var resource_manager

var movement_actions = {
	up = Vector2(0, -1),
	down = Vector2(0, 1),
	left = Vector2(-1, 0),
	right = Vector2(1, 0)
}

var special_tiles = {
	spike = "restart",
	exit = "next_level",
	demilitarized_zone = "save"
}

func _ready():
	animation_player = get_node("animation_player")
	resource_manager = get_node("/root/resource_manager")
	
	animation_player.connect("finished", self, "animation_player_finish")
	
	set_health(start_health)
	
	set_fixed_process(true)
	set_process_input(true)
	
	var cr = get_node("sprite/trail").get_color_ramp()
	printt(cr.interpolate(0), cr.interpolate(1), cr.get_colors())

func _fixed_process(delta):
	time = time + delta
	
	auto_heal = auto_heal - delta
	if(auto_heal <= 0):
		auto_heal = auto_heal_time
		add_health(1)
	
	var move = Vector2(0, 0)
	for action in movement_actions:
		if Input.is_action_pressed(action):
			move += movement_actions[action]
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	save = false
	
	if can_move:
		var force = move.normalized()*move_speed
		set_linear_velocity(get_linear_velocity() + force)
	
		if tilemap != null:
			var tile_pos = tilemap.world_to_map(get_pos())
			var tile = tilemap.get_cell(tile_pos.x, tile_pos.y)
			
			if tile > 0:
				var tile_name = tilemap.get_tileset().tile_get_name(tile)
				if special_tiles.has(tile_name):
					var tile_prop = special_tiles[tile_name]
					if tile_prop == "restart":
						can_move = false
						resource_manager.add_resource_amount("stars", -1, true)
						after_animation = "restart"
						animation_player.play("exit")
						
					elif tile_prop == "next_level":
						can_move = false
						
						after_animation = "next_level"
						animation_player.play("exit")
						
					elif tile_prop == "save":
						save = true
						auto_heal = auto_heal / 2

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		make_input_local(event)
		mouse_pos = event.pos - get_viewport_rect().size/2
	
	if event.is_action("fullscreen") && !event.is_echo() && event.is_pressed():
		fullscreen = !fullscreen
		OS.set_window_fullscreen(fullscreen)
	
	if event.is_action("show_dbg") && !event.is_echo() && event.is_pressed():
		get_node("camera").set_zoom(Vector2(8,8))

func shoot():
	if time - last_shot > 0.1 and !save:
		var new_bullet = bullet_scene.instance()
		var direction = (mouse_pos).normalized()
		var velocity = direction*new_bullet.speed*rand_range(1,1.5)
		
		new_bullet.set_pos(get_pos() + direction*bullet_offset)
		new_bullet.set_linear_velocity(velocity + get_linear_velocity())
		
		get_parent().add_child(new_bullet)
		last_shot = time

func restart_from_checkpoint():
	animation_player.play("enter")
	set_pos(last_checkpoint.get_pos())
	set_health(start_health)

func set_checkpoint(checkpoint):
	last_checkpoint = checkpoint

func add_health(amount):
	set_health(health + amount)

func set_health(amount):
	health = amount
	if health <= 0 and can_move:
		can_move = false
		resource_manager.add_resource_amount("stars", -1, true)
		
		after_animation = "restart"
		animation_player.play("exit")
		
	elif health > start_health:
		health = start_health
	
	emit_signal("health_changed")

func animation_player_finish():
	var animation_name = animation_player.get_current_animation()
	if animation_name == "enter":
		can_move = true
	elif animation_name == "exit":
		if after_animation == "restart":
			restart_from_checkpoint()
		elif after_animation == "next_level":
			get_parent().next_level()
		else:
			print(after_animation)
