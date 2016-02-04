
extends Area2D

const player_class = preload("res://player/player.gd")

export var worth = 1
var taken = false
var animation_player

func _ready():
	animation_player = get_node("animation_player")
	
	connect("body_enter",self,"_on_body_enter")
	animation_player.connect("finished", self, "animation_finished")

func _on_body_enter(body):
	if body extends player_class and not taken:
		taken = true
		get_node("/root/resource_manager").add_resource_amount("stars", worth)
		animation_player.play("take")

func animation_finished():
	if(taken):
		queue_free()
