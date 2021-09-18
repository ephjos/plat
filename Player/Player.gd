extends KinematicBody2D

const UP = Vector2(0, -1)
var velocity = Vector2()

var move_speed = 10 * 16
var jump_velocity = -400
var min_jump_velocity = -200
var gravity = 1200
var is_grounded = false

onready var raycasts = $Raycasts
onready var animPlayer = $Body/AnimatedSprite

func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func _apply_movement():
	velocity = move_and_slide(velocity, UP)
	is_grounded = _is_on_floor()
	
func _handle_move_input():
	var move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	
	if move_direction != 0:
		$Body.scale.x = move_direction
		
func _get_h_weight():
	return 0.8 if is_grounded else 0.4

func _is_on_floor():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false

func _play_animation(anim):
	if animPlayer.animation != anim:
		animPlayer.animation = anim
		animPlayer.play()
