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
var moving_right = true

onready var shotCooldown = $ShotCooldown
onready var muzzleFlash = $MuzzleFlash
onready var muzzleFlashAnimation = $MuzzleFlash/AnimationPlayer

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
		
	_update_state()
	_animate()
	_act()
	
	# Move, slide, and saved the resulting velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
# Ensure internal state is consistent before calculating physics
func _update_state():
	if has_gun:
		idle_animation = "gun_idle"
		walk_animation = "gun_walk"
	else:
		idle_animation = "idle"
		walk_animation = "walk"
		
	if velocity.x > 0:
		moving_right = true
	elif velocity.x < 0:
		moving_right = false
	
# Apply animations
func _animate():
	if velocity.x == 0:
		_play_animation(idle_animation)
	elif moving_right:
		$AnimatedSprite.flip_h = false
		_play_animation(walk_animation)
	elif !moving_right:
		$AnimatedSprite.flip_h = true
		_play_animation(walk_animation)
	
func _play_animation(name):
	if $AnimatedSprite.animation != name:
		$AnimatedSprite.animation = name
		$AnimatedSprite.play()
	
func _act():
	if has_gun and Input.is_action_just_pressed("ui_accept"):
		if !shotCooldown.is_stopped():
			return
		var bullet = Bullet.instance()
		
		if moving_right:
			bullet.transform = $GunRight.global_transform
		else:
			bullet.transform = $GunLeft.global_transform
			
		bullet.creator_id = get_instance_id()
		bullet.scale = Vector2(0.5, 0.5)
		get_parent().add_child(bullet)
		
		muzzleFlash.global_transform = bullet.global_transform
		muzzleFlashAnimation.play("Flash")
		
		shotCooldown.start()
		
