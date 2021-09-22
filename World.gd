extends Node2D

func _on_Goal_finish():
	SceneChanger.change_scene("res://World.tscn")


func _on_Goal_hit():
	Globals.LEVEL_COMPLETE = true
