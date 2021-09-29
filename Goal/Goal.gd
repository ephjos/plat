extends Area2D

signal hit;
signal finish;

onready var particles = $CPUParticles2D

onready var goalEntered = $GoalEntered

func _ready():
	Globals.GOAL = self

func _on_Goal_body_entered(body):
	emit_signal("hit")
	Globals.CAMERA.win()
	goalEntered.play()
	particles.initial_velocity = 150
	yield(get_tree().create_timer(0.5), "timeout")
	particles.emitting = false
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("finish")
	
