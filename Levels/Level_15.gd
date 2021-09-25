extends Node2D

func add_collider(position, extents):
	var static_body = StaticBody2D.new()
	add_child(static_body)
	var collider = CollisionShape2D.new()
	static_body.add_child(collider)
	
	static_body.collision_layer = 6
	collider.position = position
	collider.shape = RectangleShape2D.new()
	collider.shape.extents = extents
	
func add_fall_zone(position, extents):
	var area = Area2D.new()
	add_child(area)
	var collider = CollisionShape2D.new()
	area.add_child(collider)
	
	area.collision_layer = 6
	collider.position = position
	collider.shape = RectangleShape2D.new()
	collider.shape.extents = extents
	
	area.connect("body_entered", Globals.PLAYER, "fell", [], CONNECT_DEFERRED)
	
func _ready():
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
			
	add_collider(Vector2(left-size, top), Vector2(size, bottom-top)) # left
	add_collider(Vector2(right+size, top), Vector2(size, bottom-top)) # right
	add_collider(Vector2(left, top-size), Vector2(right-left, size)) # top
	add_collider(Vector2(left, bottom), Vector2(right-left, size)) # bottom
	add_fall_zone(Vector2(left, bottom-size-size), Vector2(right-left, size))
	
	Hud.set_level("Level_15")
	Hud.show()

func _on_Goal_finish():
	SceneChanger.change_scene("res://Levels/Level_16.tscn")

func _on_Goal_hit():
	Globals.LEVEL_COMPLETE = true

func _on_Player_dead():
	SceneChanger.change_scene("res://Levels/Level_15.tscn")
