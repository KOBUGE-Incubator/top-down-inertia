
extends RigidBody2D

export var start_health = 5.0
export var speed = 100.0
export var damage = 2.0
export var damage_cooldown = 1.0

var this_class = get_script()
var player_class = preload("res://player/player.gd")

var damage_cooldown_left = 0.0
var health = 0

var sense_area
var sprite

func _ready():
	sprite = get_node("sprite")
	sense_area = get_node("sense_area")
	health = start_health
	
	set_fixed_process(true)

func _fixed_process(delta):
	damage_cooldown_left -= delta
	
	var player_positions = Vector2Array()
	for body in sense_area.get_overlapping_bodies():
		if body extends player_class and !body.save:
			player_positions.push_back(body.get_pos() - get_pos())
	var direction = Vector2(0,0)
	if player_positions.size() <= 0:
		direction = Vector2(0,1).rotated(rand_range(0,2*PI))
		set_linear_velocity(direction*speed*rand_range(0.3,0.4) + get_linear_velocity())
	else:
		for position in player_positions:
			direction += position + Vector2(rand_range(-10,10),rand_range(-10,10))
		direction /= player_positions.size()
		direction = direction.normalized()
	
		set_linear_velocity(direction*speed*rand_range(0.9,1) + get_linear_velocity())
	
	if damage_cooldown_left <= 0:
		for body in get_colliding_bodies():
			if !body extends this_class:
				if body.has_method("add_health"):
					if body.get("save") == null or !body.save:
						body.add_health(-damage)
						damage_cooldown_left = damage_cooldown

func add_health(var amount):
	health = health + amount
	set_opacity(health/start_health/2 + 0.5)
	if(health <= 0):
		queue_free()
