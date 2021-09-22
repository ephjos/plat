extends "res://StateMachine/StateMachine.gd"

onready var playerSM = $"../PlayerSM";

func _ready():
	add_state("none")
	add_state("has_gun")
	add_state("attack")
	call_deferred("set_state", states.has_gun)
	
func _input(event):
	if event.is_action_pressed("attack") && state != states.attack && parent._can_shoot():
		parent._attack()
		set_state(states.attack)
		
func _state_logic(_delta):
	# Debug display
	parent.get_node("AttackState").text = states.keys()[state]

func _enter_state(new_state, old_state):
	match new_state:
		states.has_gun:
			# Force playerSM to update
			playerSM.set_state(playerSM.state)
		states.attack:
			if playerSM.state == playerSM.states.idle:
				parent._play_animation("gun_shoot")
			parent._play_gun_animation("shoot")
				
	return null

func _on_AnimationPlayer_animation_finished(anim_name):
	if state == states.attack:
		set_state(states.has_gun)
