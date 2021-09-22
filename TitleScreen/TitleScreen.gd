extends Control

onready var player = $HBoxContainer/CenterContainer/Player

func _ready():
	SceneChanger.hide()

func _process(delta):
	#player._play_animation("run")
	pass
	
func _start():
	SceneChanger.show()
	SceneChanger.change_scene("res://World.tscn")

func _on_Button_pressed():
	_start()

func _on_StaticBody2D_hit():
	_start()
