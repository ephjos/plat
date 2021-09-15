extends "res://StateMachine/StateMachine.gd"

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	call_deferred("set_state", states.idle)
