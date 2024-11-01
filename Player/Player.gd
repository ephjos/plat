extends KinematicBody2D
class_name Player

signal dead

const Bullet : PackedScene = preload("res://Bullet/Bullet.tscn")

# Constants
const MOVE_SPEED = 10 * Globals.TILE_SIZE # 10 tiles per second
const JUMP_SPEED = -425
const MIN_JUMP_SPEED = -200
const WALL_SLIDE_GRAVITY = 64
const WALL_JUMP_VECTOR = Vector2(MOVE_SPEED*2, JUMP_SPEED*1.2)

var velocity = Vector2()
var is_grounded = false
var move_direction = 0
var wall_direction = 1
var can_shoot = true
var health = 3
var dead = false

onready var body = $Body
onready var muzzle = $Body/Muzzle

onready var animPlayer = $Body/AnimatedSprite
onready var gunAnimPlayer = $Body/Muzzle/Flash/AnimationPlayer
onready var bodyPlayer = $Body/BodyPlayer

onready var wallJumpTimer = $WallJumpTimer
onready var wallStickTimer = $WallStickTimer
onready var coyoteTimer = $CoyoteTimer
onready var invulnTimer = $InvulnTimer

onready var floorRaycasts = $FloorRaycasts
onready var leftWallRaycasts = $WallRaycasts/Left
onready var rightWallRaycasts = $WallRaycasts/Right
onready var muzzleCheck = $Body/MuzzleCheck

onready var hurtSound = $Hurt
onready var deadSound = $Dead
onready var jumpSound = $Jump

func _ready():
	Globals.PLAYER = self
	Hud.set_health(health)

func _jump():
	velocity.y = JUMP_SPEED
	jumpSound.play()
	
func _variable_jump():
	velocity.y = MIN_JUMP_SPEED
	
func _wall_jump():
	var wall_jump_vector = WALL_JUMP_VECTOR
	wall_jump_vector.x *= -wall_direction
	velocity = wall_jump_vector
	jumpSound.play()
	
func _apply_gravity(delta):
	velocity.y += Globals.GRAVITY * delta
	
func _cap_wall_slide_gravity():
	# If pressing down, add 10x gravity
	var modifier = int(Input.get_action_strength("move_down"))*10*WALL_SLIDE_GRAVITY
	velocity.y = min(velocity.y, WALL_SLIDE_GRAVITY + (modifier))

# Apply and update velocity, update is_grounded
func _apply_movement():
	velocity = move_and_slide(velocity, Globals.UP)
	is_grounded = _is_on_floor()
	
# Apply user input to velocity
func _handle_move_input():
	velocity.x = lerp(velocity.x, MOVE_SPEED * move_direction, _get_h_weight())
	
	# Flip sprite to face movement direction
	if move_direction != 0:
		body.scale.x = sign(move_direction)
		
# Return the interpolation coefficient, higher = more control 
func _get_h_weight():
	if is_grounded:
		return 0.8
		
	# If on wall or just left wall, reduce control
	if wall_direction != 0 || !wallJumpTimer.is_stopped():
		return 0.02
	
	# Less control in air
	return 0.4

func _update_move_direction():
	move_direction = -float(Input.get_action_strength("move_left")) \
		+ float(Input.get_action_strength("move_right"))
	
# Check for walls
func _update_wall_direction():
	var is_left = _is_on_wall(leftWallRaycasts)
	var is_right = _is_on_wall(rightWallRaycasts)
	
	if is_left && is_right:
		wall_direction = sign(move_direction)
	else:
		wall_direction = -int(is_left) + int(is_right)
	
# If all raycasts on provided side are colliding with a wall, return true
func _is_on_wall(raycasts):
	for raycast in raycasts.get_children():
		if !raycast.is_colliding():
			return false
	return true

# If any floor raycast is colliding, return true
func _is_on_floor():
	for raycast in floorRaycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
	
# Add delay before moving off of wall, give window to jump
func _handle_wall_slide_stick():
	if move_direction != 0 && move_direction != wall_direction:
		if wallStickTimer.is_stopped():
			wallStickTimer.start()
	else:
		wallStickTimer.stop()
		
func _can_shoot():
	if dead || Globals.LEVEL_COMPLETE:
		return false
	return !muzzleCheck.is_colliding()
		
func _attack():
	var bullet = Bullet.instance()
	owner.add_child(bullet)
	bullet.transform = muzzle.global_transform
	Globals.CAMERA.set_trauma(0.12)
	
# Ensure animation is not needlessly restarted
func _play_animation(anim):
	if animPlayer.animation != anim:
		animPlayer.animation = anim
		animPlayer.play()
		
func _play_gun_animation(anim):
	gunAnimPlayer.play(anim)

func hit():
	if Globals.LEVEL_COMPLETE:
		return
		
	if !invulnTimer.is_stopped():
		return
	
	hurtSound.play()
	health -= 1
	Hud.set_health(health)
	invulnTimer.start()
	bodyPlayer.play("hurt")
	if health == 0:
		die()
	Globals.CAMERA.add_trauma(0.3)
		
func fell(body):
	if body != self:
		return
	health = 0
	bodyPlayer.play("hurt")
	Hud.set_health(health)
	die()

func die():
	dead = true
	deadSound.play()
	Globals.CAMERA.add_trauma(0.5)
	emit_signal("dead")
