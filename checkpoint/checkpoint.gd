
extends Area2D

var player_class = preload("res://player/player.gd")

func _ready():
	connect("body_enter",self,"_on_body_enter")
	connect("body_exit",self,"_on_body_exit")

func _on_body_enter(body):
	if(body extends player_class):
		body.set_checkpoint(self)
		get_node("particles").set_emitting(true)

func _on_body_exit(body):
	if(body extends player_class):
		get_node("particles").set_emitting(false)
