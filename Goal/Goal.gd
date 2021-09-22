extends Area2D

signal finish;

onready var particles = $CPUParticles2D

func _on_Goal_body_entered(body):
	particles.initial_velocity = 150
	yield(get_tree().create_timer(0.5), "timeout")
	particles.emitting = false
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("finish")
	
