extends TileMap
class_name Grid

enum { INVALID = -1, GRASS = 0, TREE = 1, MOUNTAIN = 2 }

var tiles
var blocked_tiles

# Called when the node enters the scene tree for the first time.
func _ready():
	BuildTiles()


func BuildTiles():
	var pos = get_used_rect().position
	var size = get_used_rect().size

	# Fill empty tiles 2d array with -1
	tiles = []
	blocked_tiles = []
	for y in range(0, size.y):
		tiles.append([])
		blocked_tiles.append([])
		for x in range(0, size.x):
			tiles[y].append(INVALID)
			blocked_tiles[y].append(0)

	# Fill tiles with tile type
	for i in range(0, get_layers_count()):
		for tile in get_used_cells(i):
			var y = tile.y - pos.y
			var x = tile.x - pos.x
			tiles[y][x] = i
			blocked_tiles[y][x] = 0 if i == GRASS else 1


func GetTileType(pos):
	var x = pos.x
	var y = pos.y

	if y < 0 or y >= tiles.size() or x < 0 or x >= tiles[y].size():
		return INVALID
	
	return tiles[y][x]


func IsTileBlocked(pos):
	var x = pos.x
	var y = pos.y

	if y < 0 or y >= blocked_tiles.size() or x < 0 or x >= blocked_tiles[y].size():
		return true
	
	return blocked_tiles[y][x] == 1


func BlockUnBlock(pos, block):
	var x = pos.x
	var y = pos.y

	if y < 0 or y >= blocked_tiles.size() or x < 0 or x >= blocked_tiles[y].size():
		return
	
	blocked_tiles[y][x] = 1 if block else 0
