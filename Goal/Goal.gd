extends Area2D

signal hit;
signal finish;

onready var particles = $CPUParticles2D

func _ready():
	Globals.GOAL = self

func _on_Goal_body_entered(body):
	emit_signal("hit")
	particles.initial_velocity = 150
	yield(get_tree().create_timer(0.5), "timeout")
	particles.emitting = false
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("finish")
	
