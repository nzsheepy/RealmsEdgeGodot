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


func GetTilesTypeRange(start, end):
	var x = min(start.x, end.x)
	var y = min(start.y, end.y)
	var x_end = max(start.x, end.x)
	var y_end = max(start.y, end.y)

	if y < 0 or y >= tiles.size() or x < 0 or x >= tiles[y].size():
		return INVALID
	
	if y_end < 0 or y_end >= tiles.size() or x_end < 0 or x_end >= tiles[y_end].size():
		return INVALID

	var tile_type = tiles[y][x]
	for i in range(y, y_end + 1):
		for j in range(x, x_end + 1):
			if tiles[i][j] != tile_type:
				return INVALID
	
	return tile_type


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


func BlockUnBlockRange(start, end, block):
	var x = min(start.x, end.x)
	var y = min(start.y, end.y)
	var x_end = max(start.x, end.x)
	var y_end = max(start.y, end.y)

	if y < 0 or y >= blocked_tiles.size() or x < 0 or x >= blocked_tiles[y].size():
		return
	
	if y_end < 0 or y_end >= blocked_tiles.size() or x_end < 0 or x_end >= blocked_tiles[y_end].size():
		return

	for i in range(y, y_end + 1):
		for j in range(x, x_end + 1):
			blocked_tiles[i][j] = 1 if block else 0
