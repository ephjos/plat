extends CanvasLayer

onready var player = $HBoxContainer/CenterContainer/Player

func _ready():
	Hud.hide()
	player.body.scale.x = -1

func _start():
	SceneChanger.change_scene("res://Levels/Level_01.tscn", 0)

func _on_Button_pressed():
	_start()

func _on_StaticBody2D_hit():
	_start()
