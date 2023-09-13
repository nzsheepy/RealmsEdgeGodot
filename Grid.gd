extends TileMap
class_name Grid

enum { INVALID = -1, GRASS = 0, TREE = 1, MOUNTAIN = 2 }

var tiles

# Called when the node enters the scene tree for the first time.
func _ready():
	BuildTiles()


func BuildTiles():
	var pos = get_used_rect().position
	var size = get_used_rect().size

	# Fill empty tiles 2d array with -1
	tiles = []
	for y in range(0, size.y):
		tiles.append([])
		for x in range(0, size.x):
			tiles[y].append(INVALID)

	# Fill tiles with tile type
	for i in range(0, get_layers_count()):
		for tile in get_used_cells(i):
			var y = tile.y - pos.y
			var x = tile.x - pos.x
			tiles[y][x] = i


func GetTileType(pos):
	var x = pos.x
	var y = pos.y

	if y < 0 or y >= tiles.size() or x < 0 or x >= tiles[y].size():
		return INVALID
	
	return tiles[y][x]


