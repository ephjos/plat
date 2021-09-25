extends CanvasLayer

onready var health = $Health
onready var health0 = $"Health/0"
onready var health1 = $"Health/1"
onready var health2 = $"Health/2"
onready var health3 = $"Health/3"

onready var levelLabel = $Level/Label

func set_health(health):
	health0.show()
	health1.show()
	health2.show()
	health3.show()
	
	if health < 3:
		health3.hide()
	if health < 2:
		health2.hide()
	if health < 1:
		health1.hide()
		
func set_level(level):
	levelLabel.text = level

func hide():
	health.hide()
	levelLabel.hide()
	
func show():
	health.show()
	levelLabel.show()
