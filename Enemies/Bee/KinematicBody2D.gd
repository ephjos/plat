extends KinematicBody2D

func hit():
	get_parent().queue_free()
