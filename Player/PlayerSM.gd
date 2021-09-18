extends "res://StateMachine/StateMachine.gd"

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", states.idle)
	
func _input(event):
	if [states.idle, states.run].has(state):
		if event.is_action_pressed("jump"):
			parent.velocity.y = parent.jump_velocity
	
	if state == states.jump:
		if event.is_action_released("jump") && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity

func _state_logic(delta):
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()
	parent.get_node("StateLabel").text = states.keys()[state]
	
func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif abs(parent.velocity.x) > 0.1:
				return states.run
		states.run:
			print(parent.velocity.x)
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif abs(parent.velocity.x) <= 0.1:
				return states.idle
		states.jump:
			if parent.is_grounded:
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.is_grounded:
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
	return null
	
func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent._play_animation("idle")
		states.run:
			parent._play_animation("run")
		states.jump:
			parent._play_animation("jump")
		states.fall:
			parent._play_animation("fall")
			
	return null
	
func _exit_state(old_state, new_state):
	pass
