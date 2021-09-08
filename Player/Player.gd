extends KinematicBody2D

export (int) var move_speed = 200
export (int) var jump_speed = -420

export (int) var gravity = 1500

export (bool) var has_gun = false
export (String) var idle_animation = "idle"
export (String) var walk_animation = "walk"

var velocity = Vector2()
var jumping = false
var double_jumping = false
var last_on_floor = 0

func _ready():
	pass
	
func _physics_process(delta):
	_update_state()
	
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
	
	# Move, slide, and saved the resulting velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	_animate(velocity)

# Ensure internal state is consistent before calculating physics
func _update_state():
	if has_gun:
		idle_animation = "gun_idle"
		walk_animation = "gun_walk"
	else:
		idle_animation = "idle"
		walk_animation = "walk"
	
# Apply animations	
func _animate(velocity):
  # if is_on_floor():
	if velocity.x == 0:
		$AnimatedSprite.animation = idle_animation
		$AnimatedSprite.stop()
	elif velocity.x > 0:
		$AnimatedSprite.animation = walk_animation
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play()
	elif velocity.x < 0:
		$AnimatedSprite.animation = walk_animation
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play()
	
