extends CanvasLayer

export(String, "slide_in", "slide_out", "fade") var animIn = "slide_in"
export(String, "slide_in", "slide_out", "fade") var animOut = "slide_out"

onready var animPlayer = $AnimationPlayer

func _process(delta):
	if !Globals.PLAY_MUSIC:
		$Music.stop()
	elif $Music.playing == false:
		$Music.play()
		$Music.autoplay = true

func change_scene(path, delay = 0.5):
	yield(get_tree().create_timer(delay), "timeout")
	animPlayer.play(animIn)
	yield(animPlayer, "animation_finished")
	get_tree().change_scene(path) == OK
	animPlayer.play(animOut)
	Globals.LEVEL_COMPLETE = false
	yield(animPlayer, "animation_finished")

func reload_scene(delay = 0.5):
	yield(get_tree().create_timer(delay), "timeout")
	animPlayer.play(animIn)
	yield(animPlayer, "animation_finished")
	get_tree().reload_current_scene() == OK
	animPlayer.play(animOut)
	Globals.LEVEL_COMPLETE = false
	yield(animPlayer, "animation_finished")
	
func hide():
	get_child(0).hide()
	
func show():
	get_child(0).show()
