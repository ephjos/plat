extends "res://StateMachine/StateMachine.gd"

onready var attackSM = $"../AttackSM";

var allAnimations = {
	"default": {
		"idle": "idle",
		"run": "run",
		"jump": "jump",
		"fall": "fall",
	},
	"gun": {
		"idle": "gun_idle",
		"run": "gun_run",
		"jump": "gun_jump",
		"fall": "gun_fall",
	}
}

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	call_deferred("set_state", states.idle)
	
func _input(event):
	if event.is_action_pressed("jump"):
		# Normal grounded jump
		if [states.idle, states.run].has(state):
			parent._jump()
		
		# If falling but still in coyote time
		if state == states.fall && !parent.coyoteTimer.is_stopped():
			parent.coyoteTimer.stop()
			parent._jump()

		# If on a wall
		if state == states.wall_slide:
			parent._wall_jump()
			set_state(states.jump)
	
	# If jumping and space was released, perform a shorter jump
	if [states.idle, states.run, states.jump].has(state):
		if event.is_action_released("jump") && parent.velocity.y < parent.MIN_JUMP_SPEED:
			parent._variable_jump()
		
func _state_logic(delta):
	if parent.dead:
		parent.rotation += 0.2
		parent.position.y -= 2
		return
	if Globals.LEVEL_COMPLETE:
		parent.rotation -= 0.2
		parent.scale /= 1.03
		parent.position = lerp(parent.position, Globals.GOAL.position, 0.2)
		return
	parent._update_move_direction()
	parent._update_wall_direction()
	if state != states.wall_slide:
		parent._handle_move_input()
	parent._apply_gravity(delta)
	if state == states.wall_slide:
		parent._cap_wall_slide_gravity()
		parent._handle_wall_slide_stick()
	parent._apply_movement()
	
	if Globals.DEBUG:
		parent.get_node("PlayerState").text = states.keys()[state]
	
func _get_transition(delta):
	var x = parent.velocity.x
	var y = parent.velocity.y
	var is_grounded = parent.is_grounded
	print(is_grounded)
	match state:
		states.idle:
			if !is_grounded:
				if y < 0:
					return states.jump
				elif y > 0:
					return states.fall
			elif abs(x) > 0.1:
				return states.run
		states.run:
			if !is_grounded:
				if y < 0:
					return states.jump
				elif y > 0:
					return states.fall
			elif abs(x) <= 0.1:
				return states.idle
		states.jump:
			if parent.wall_direction != 0 && parent.wallJumpTimer.is_stopped():
				return states.wall_slide
			if is_grounded:
				return states.idle
			elif y >= 0:
				return states.fall
		states.fall:
			if parent.wall_direction != 0 && parent.wallJumpTimer.is_stopped():
				return states.wall_slide
			if is_grounded:
				return states.idle
			elif y < 0:
				return states.jump
		states.wall_slide:
			if is_grounded:
				return states.idle
			if parent.wall_direction == 0:
				return states.fall
			
	return null
	
func _enter_state(new_state, old_state):
	var animations
	if attackSM.state == attackSM.states.none:
		animations = allAnimations.default
	else:
		animations = allAnimations.gun
	
	match new_state:
		states.idle:
			parent._play_animation(animations.idle)
		states.run:
			parent._play_animation(animations.run)
		states.jump:
			parent._play_animation(animations.jump)
		states.fall:
			parent._play_animation(animations.fall)
			# Enter coyote time when running off a ledge
			if old_state == states.run:
				parent.coyoteTimer.start()
		states.wall_slide:
			#parent._play_animation("wall_slide")
			# Face away from the wall
			parent.body.scale.x = -parent.wall_direction
				
	return null
	
func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wallJumpTimer.start()

func _on_WallStickTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)
