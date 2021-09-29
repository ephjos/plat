extends Node2D
class_name Bullet

export var SPEED = 500
onready var animPlayer = $AnimationPlayer

onready var hit = $Hit
onready var enemyHit = $EnemyHit

func _physics_process(delta):
	position += transform.x * SPEED * delta
	#position.y += 1
	
func _on_Area2D_body_entered(body):
	if body.has_method("hit"):
		body.hit()
		enemyHit.play()
	else:
		hit.play()
		
	set_physics_process(false)
	animPlayer.play("hit")
	yield(animPlayer, "animation_finished");
	queue_free()
