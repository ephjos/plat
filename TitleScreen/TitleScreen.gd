extends Control

onready var player = $HBoxContainer/CenterContainer/Player

func _ready():
	SceneChanger.hide()

func _process(delta):
	player._play_animation("run")

func _on_Button_pressed():
	SceneChanger.show()
	SceneChanger.change_scene("res://World.tscn")
