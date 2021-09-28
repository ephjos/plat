extends PathFollow2D

onready var kinematicBody = $KinematicBody2D
onready var sprite = $KinematicBody2D/AnimatedSprite

export var movement = 0.5
export var vertical_movement = 2
export var amplitude = 0.25

var length
var time = 0

func _ready():
	length = get_parent().get_curve().get_baked_length()
	sprite.scale.x *= sign(movement)

func _physics_process(delta):
	time += delta
	if time > 2*PI:
		time = 0
	if offset + movement >= length || offset + movement <= 0:
		movement *= -1
		sprite.scale.x *= -1
	offset += movement
	v_offset += sin(time*vertical_movement) * amplitude
	
func _on_Hurtbox_body_entered(body):
	if body == kinematicBody:
		return
		
	if body.has_method("hit"):
		body.hit()

