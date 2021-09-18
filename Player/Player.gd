extends KinematicBody2D

const UP = Vector2(0, -1)
var velocity = Vector2()

var move_speed = 10 * 16
var jump_velocity = -425
var min_jump_velocity = -200
var gravity = 1200
var wall_slide_gravity = 64
var is_grounded = false
var move_direction
var wall_direction = 1

onready var body = $Body
onready var animPlayer = $Body/AnimatedSprite
onready var wallJumpTimer = $WallJumpTimer
onready var wallStickTimer = $WallStickTimer
onready var coyoteTimer = $CoyoteTimer

onready var floorRaycasts = $FloorRaycasts
onready var leftWallRaycasts = $WallRaycasts/Left
onready var rightWallRaycasts = $WallRaycasts/Right

func jump():
	velocity.y = jump_velocity
	
func variable_jump():
	velocity.y = min_jump_velocity
	
func wall_jump():
	var wall_jump_velocity = Vector2(200, -400)
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity
	
func _cap_wall_slide_gravity():
	var modifier = int(Input.is_action_pressed("move_down"))*10
	velocity.y = min(velocity.y, wall_slide_gravity + (modifier*wall_slide_gravity))
	
func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func _apply_movement():
	velocity = move_and_slide(velocity, UP)
	is_grounded = _is_on_floor()
	
func _handle_move_input():
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	
	if move_direction != 0:
		body.scale.x = move_direction
		
func _handle_wall_slide_stick():
	if move_direction != 0 && move_direction != wall_direction:
		if wallStickTimer.is_stopped():
			wallStickTimer.start()
	else:
		wallStickTimer.stop()
		
func _get_h_weight():
	if is_grounded:
		return 0.8
		
	if !wallJumpTimer.is_stopped():
		return 0.02
	return 0.4
	
func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	
func _update_wall_direction():
	var is_left = _is_on_wall(leftWallRaycasts)
	var is_right = _is_on_wall(rightWallRaycasts)
	
	if is_left && is_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_left) + int(is_right)
	
func _is_on_wall(raycasts):
	for raycast in raycasts.get_children():
		if !raycast.is_colliding():
			return false
	return true

func _is_on_floor():
	for raycast in floorRaycasts.get_children():
		if raycast.is_colliding():
			return true
	return false

func _play_animation(anim):
	if animPlayer.animation != anim:
		animPlayer.animation = anim
		animPlayer.play()
