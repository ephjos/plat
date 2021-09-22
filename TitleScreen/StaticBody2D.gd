extends StaticBody2D

signal hit

func hit():
	emit_signal("hit")
