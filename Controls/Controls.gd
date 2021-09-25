extends CanvasLayer


func _input(event):
	if event is InputEventKey || event is InputEventJoypadButton:
		if event.is_pressed():
			SceneChanger.change_scene("res://TitleScreen/TitleScreen.tscn", 0)
