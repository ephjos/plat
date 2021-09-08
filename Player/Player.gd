extends KinematicBody2D

const Bullet : PackedScene = preload("res://Bullet/Bullet.tscn")

export (int) var move_speed = 175
export (int) var jump_speed = -420

export (int) var gravity = 1500

export (bool) var has_gun = true
export (String) var idle_animation = "idle"
export (String) var walk_animation = "walk"

var velocity = Vector2()
var jumping = false
var double_jumping = false
var last_on_floor = 0
var moving_direction = 1

func _ready():
	pass
	
func _physics_process(delta):
	# Move left or right
	velocity.x = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * move_speed
	
	# Time since last_on_floor
	if is_on_floor():
		last_on_floor = 0
	last_on_floor += delta
	
	# Handle jump request
	var jump = Input.is_action_just_pressed("ui_up")
	if jump and last_on_floor < 0.1: # first jump must happen with coyote time
		jumping = true
		velocity.y = jump_speed
	elif jump and !double_jumping: # double jump 
		double_jumping = true
		velocity.y = jump_speed
		
	# Apply gravity
	velocity.y += gravity * delta

	# Allow jumping if on the ground
	if (jumping or double_jumping) and is_on_floor():
		jumping = false
		double_jumping = false
		
	_update_state(velocity)
	_animate(velocity)
	_act(velocity)
	
	# Move, slide, and saved the resulting velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
# Ensure internal state is consistent before calculating physics
func _update_state(velocity):
	if has_gun:
		idle_animation = "gun_idle"
		walk_animation = "gun_walk"
	else:
		idle_animation = "idle"
		walk_animation = "walk"
		
	if velocity.x > 0:
		moving_direction = 1
	elif velocity.x < 0:
		moving_direction = -1
	
	
# Apply animations	
func _animate(velocity):
	if velocity.x == 0:
		$AnimatedSprite.animation = idle_animation
		$AnimatedSprite.stop()
	elif moving_direction == 1:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = walk_animation
		$AnimatedSprite.play()
	elif moving_direction == -1:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.animation = walk_animation
		$AnimatedSprite.play()
	
func _act(velocity):
	if has_gun and Input.is_action_just_pressed("ui_accept"):
		var bullet_position = Vector2(position.x + (moving_direction*7), position.y+3)
		
		var bullet = Bullet.instance()
		bullet.creator_id = get_instance_id()
		bullet.position = bullet_position
		bullet.scale *= 0.5
		
		if moving_direction == -1:
			bullet.rotation = PI
		owner.add_child(bullet)
