extends KinematicBody2D

const Bullet : PackedScene = preload("res://Bullet/Bullet.tscn")
const StepParticles : PackedScene = preload("res://Animation/StepParticles.tscn")
const JumpParticles : PackedScene = preload("res://Animation/JumpParticles.tscn")

export (int) var move_speed = 200
export (int) var jump_speed = -350

export (int) var gravity = 1000

export (String) var idle_animation = "Idle"
export (String) var walk_animation = "Walk"
export (bool) var has_gun = true
export (String) var shoot_animation = "Gun Shoot"

var velocity = Vector2()
var jumping = false
var double_jumping = false
var last_on_floor = 0

var moving_dir = 1
var facing_right = true

onready var animationPlayer = $AnimationPlayer
onready var stepParticleCooldown = $StepParticleCooldown
onready var shotCooldown = $ShotCooldown
onready var muzzleFlash = $MuzzleFlash
onready var muzzleFlashAnimation = $MuzzleFlash/AnimationPlayer

func _ready():
	pass
	
func _physics_process(delta):
	# Move left or right
	velocity.x = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * move_speed
	
	# Time since last_on_floor
	if is_on_floor():
		last_on_floor = 0
		velocity.y = 0
	last_on_floor += delta
	
	# Handle jump request
	var jump = Input.is_action_just_pressed("move_up")
	if jump and last_on_floor < 0.1: # first jump must happen with coyote time
		jumping = true
		velocity.y = jump_speed
		_play_jump_particles()
	elif jump and !double_jumping: # double jump 
		double_jumping = true
		velocity.y = jump_speed
		
	# Apply gravity
	velocity.y += gravity * delta
	
	_update_state()
	_animate()
	_act()

	# Allow jumping if on the ground
	if (jumping or double_jumping) and is_on_floor():
		jumping = false
		double_jumping = false

	# Move, slide, and saved the resulting velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
# Ensure internal state is consistent before calculating physics
func _update_state():
	if has_gun:
		idle_animation = "Gun Idle"
		walk_animation = "Gun Walk"
	else:
		idle_animation = "Idle"
		walk_animation = "Walk"
		
	if velocity.x == 0:
		moving_dir = 0
	elif velocity.x > 0:
		moving_dir = 1
	elif velocity.x < 0:
		moving_dir = -1
		
	if facing_right and moving_dir < 0:
		_flip()
	if !facing_right and moving_dir > 0:
		_flip()
		
func _flip():
	facing_right = !facing_right
	$Sprite.flip_h = !$Sprite.flip_h
	
# Apply animations
func _animate():
	if has_gun and Input.is_action_just_pressed("attack") and moving_dir == 0:
		_play_animation(shoot_animation)
	elif moving_dir == 0:
		_play_animation(idle_animation)
	elif is_on_floor():
		_play_animation(walk_animation)
		_play_particles()
		
func _play_particles():
	if !stepParticleCooldown.is_stopped():
		return
		
	var particles = StepParticles.instance()
	particles.emitting = true
	particles.global_position = Vector2(global_position.x, global_position.y + 8)
	get_parent().add_child(particles)
	stepParticleCooldown.start()
	
func _play_jump_particles():
	var particles = JumpParticles.instance()
	particles.emitting = true
	particles.global_position = Vector2(global_position.x, global_position.y + 8)
	get_parent().add_child(particles)
	
func _play_animation(name):
	if animationPlayer.is_playing() and animationPlayer.current_animation == name:
		return
	if animationPlayer.is_playing() and animationPlayer.current_animation == shoot_animation:
		return
	animationPlayer.play(name)
	
func _act():
	if has_gun and Input.is_action_just_pressed("attack"):
		if !shotCooldown.is_stopped():
			return
			
		var bullet = Bullet.instance()
		
		if facing_right:
			bullet.transform = $GunRight.global_transform
		else:
			bullet.transform = $GunLeft.global_transform
			
		bullet.creator_id = get_instance_id()
		bullet.scale = Vector2(0.5, 0.5)
		get_parent().add_child(bullet)
		
		muzzleFlash.global_transform = bullet.global_transform
		muzzleFlashAnimation.play("Flash")
		
		shotCooldown.start()
		
