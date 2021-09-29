extends KinematicBody2D

export var movement = 50

onready var sprite = $AnimatedSprite
onready var floorRaycasts = $FloorRaycasts
onready var sideRaycasts = $SideRaycasts

func hit():
	queue_free()

func _ready():
	sprite.scale.x *= sign(movement)
	
func _near_edge():
	for raycast in floorRaycasts.get_children():
		if !raycast.is_colliding():
			return true
	return false	
	
func _near_wall():
	for raycast in sideRaycasts.get_children():
		if raycast.is_colliding():
			return true
	return false

func _physics_process(delta):
	if _near_wall() || _near_edge():
		movement *= -1
		sprite.scale.x *= -1
	move_and_slide(Vector2(movement, 0), Globals.UP)

func _on_Hurtbox_body_entered(body):	
	if body == self:
		return
		
	if body.has_method("hit"):
		body.hit()


