extends CanvasLayer

onready var player = $HBoxContainer/CenterContainer/Player

func _ready():
	SceneChanger.hide()
	Hud.hide()
