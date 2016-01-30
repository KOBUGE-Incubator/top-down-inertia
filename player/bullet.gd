
extends RigidBody2D

export var lives = 1
export var life_time = 1.0
export var initial_time = 1.0
export var damage = 1.0
export var speed = 2.0

var dangerous = true
var this_class = get_script()
var animation_player
var layer_mask
var collision_mask

func _ready():
	animation_player = get_node("animation_player")
	animation_player.connect("finished", self, "animation_finished")
	
	life_time = life_time * rand_range(1,1.3)
	animation_player.play("enter")
	
	layer_mask = get_layer_mask()
	collision_mask = get_collision_mask()
	
	set_layer_mask(0)
	set_collision_mask(0)
	
	set_fixed_process(true)

func die():
	if(animation_player.get_current_animation() != "exit"):
		set_layer_mask(16384)
		lives = 0
		dangerous = false
		animation_player.play("exit")

func _fixed_process(delta):
	life_time = life_time - delta
	
	if life_time <= 0:
		die()
	if initial_time != null:
		if initial_time <= 0:
			initial_time = null
			set_layer_mask(0)
			set_collision_mask(0)
		else:
			initial_time = initial_time - delta
	else:
		set_layer_mask(layer_mask)
		set_collision_mask(collision_mask)
		
		var collisions = get_colliding_bodies()
		for body in collisions:
			if !body extends this_class and dangerous:
				lives = lives - 1
				if(body.has_method("add_health")):
					body.add_health(-damage)
				if(lives <= 0):
					die()

func animation_finished():
	if(lives <= 0):
		queue_free()
