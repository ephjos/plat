extends Camera2D

export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 50)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
onready var noise = OpenSimplexNoise.new()
var noise_y = 0

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	
	limit_left = 0
	limit_right = 0
	limit_bottom = 0
	
	var tilemaps = get_tree().get_nodes_in_group("tilemap")
	for tilemap in tilemaps:
		if tilemap is TileMap:
			var used = tilemap.get_used_rect()
			limit_left = min(used.position.x * tilemap.cell_size.x, limit_left)
			limit_right = max(used.end.x * tilemap.cell_size.x, limit_right)
			limit_bottom = max(used.end.y * tilemap.cell_size.y, limit_bottom)
	Globals.CAMERA = self

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
		
func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
	
func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	
func set_trauma(amount):
	trauma = max(amount, trauma)
	
func win():
	$Tween.interpolate_property(self, "zoom", zoom, Vector2(0.25, 0.25), 1.0)
	$Tween.start()
