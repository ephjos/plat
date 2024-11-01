extends Control

onready var player = $HBoxContainer/CenterContainer/Player

onready var controls1 = $HBoxContainer/VBoxContainer/Controls1
onready var controls2 = $HBoxContainer/VBoxContainer/Controls2


var scroll = 0

func add_collider(position, extents):
	var static_body = StaticBody2D.new()
	add_child(static_body)
	var collider = CollisionShape2D.new()
	static_body.add_child(collider)
	
	static_body.collision_layer = 6
	collider.position = position
	collider.shape = RectangleShape2D.new()
	collider.shape.extents = extents

func _ready():
	controls2.hide()
	Hud.hide()
	
	var left = 0
	var right = 0
	var top = 0
	var bottom = 0
	var size = 5
	
	var tilemaps = get_tree().get_nodes_in_group("tilemap")
	for tilemap in tilemaps:
		if tilemap is TileMap:
			var used = tilemap.get_used_rect()
			left = used.position.x * tilemap.cell_size.x
			right = used.end.x * tilemap.cell_size.x
			top = used.position.y * tilemap.cell_size.y
			bottom = used.end.y * tilemap.cell_size.y
	
	bottom *= 2
	right *= 2
			
	add_collider(Vector2(left-size, top), Vector2(size, bottom-top)) # left
	add_collider(Vector2(right+size, top), Vector2(size, bottom-top)) # right
	add_collider(Vector2(left, top-size), Vector2(right-left, size)) # top
	add_collider(Vector2(left, bottom), Vector2(right-left, size)) # bottom

func _start():
	SceneChanger.change_scene("res://Levels/Level_01.tscn", 0)
	
func _process(delta):
	scroll = lerp(scroll, 128, 0.05)
	$ParallaxBackground.scroll_offset.x -= scroll * delta

func _on_Button_pressed():
	_start()

func _on_StaticBody2D_hit():
	_start()

func _input(event):
	if event.is_action_pressed("jump"):
		SceneChanger.change_scene("res://Levels/Level_01.tscn", 0)
	if event.is_action_pressed("controls"):
		SceneChanger.change_scene("res://Controls/Controls.tscn", 0)


func _on_ControlsTimer_timeout():
	if controls1.visible:
		controls1.hide()
		controls2.show()
	else:
		controls2.hide()
		controls1.show()
