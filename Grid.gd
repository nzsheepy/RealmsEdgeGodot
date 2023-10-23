extends TileMap
class_name Grid

enum { INVALID = -1, GRASS = 0, TREE = 1, MOUNTAIN = 2 }

var tiles
var blocked_tiles

var oldNavPolygon : NavigationPolygon
var oldDuplicate : NavigationPolygon
var navPolygons = []
var tiledata : TileData

var run_once = true

# Called when the node enters the scene tree for the first time.
func _init():
	_buildTiles()

	var atlasSource: TileSetAtlasSource = tile_set.get_source(4)
	tiledata = atlasSource.get_tile_data(Vector2i(0, 0), 0)
	oldNavPolygon = tiledata.get_navigation_polygon(0)
	oldDuplicate = oldNavPolygon.duplicate()
	for i in range(0, oldNavPolygon.get_polygon_count()):
		navPolygons.append(oldNavPolygon.get_polygon(i))
	
	oldNavPolygon.clear_polygons()
	tile_set.remove_navigation_layer(0)

	var layer = 3
	print("Starting to fill navigation layer")
	# Fill layer with tile Navigation tile
	for y in range(0, blocked_tiles.size()):
		for x in range(0, blocked_tiles[y].size()):
			var x_offset = x + get_used_rect().position.x
			var y_offset = y + get_used_rect().position.y
			if blocked_tiles[y][x] == 0:
				set_cell(layer, Vector2i(x_offset, y_offset), 4, Vector2i(0, 0))

	print("done init")


func _process(_delta):
	if run_once:
		run_once = false
		call_deferred("updateNav")


func updateNav():
	tile_set.add_navigation_layer(0)
	#var newNavPolygon = oldNavPolygon.duplicate()

	# for i in range(0, navPolygons.size()):
	# 	newNavPolygon.add_polygon(navPolygons[i])

	tiledata.set_navigation_polygon(0, oldDuplicate)
	print("Navigation Updated")


func _buildTiles():
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


## Gets the tile type at the given position
func GetTileType(pos):
	var x = pos.x
	var y = pos.y

	if y < 0 or y >= tiles.size() or x < 0 or x >= tiles[y].size():
		return INVALID
	
	return tiles[y][x]


## Gets the tile type of a range, if all tiles are the same type
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


## Gets whether the tile at the given position is blocked
func IsTileBlocked(pos):
	var x = pos.x
	var y = pos.y

	if y < 0 or y >= blocked_tiles.size() or x < 0 or x >= blocked_tiles[y].size():
		return true
	
	return blocked_tiles[y][x] == 1


## Blocks or unblocks the tile at the given position
func BlockUnBlock(pos, block):
	var x = pos.x
	var y = pos.y

	if y < 0 or y >= blocked_tiles.size() or x < 0 or x >= blocked_tiles[y].size():
		return
	
	blocked_tiles[y][x] = 1 if block else 0


## Blocks or unblocks a range of tiles
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


## Convert a world position to a tile position
func WorldToTilePos(world_pos):
	var tile_size = cell_quadrant_size
	var offset = get_used_rect().position * tile_size
	var x = floor((world_pos.x - offset.x) / tile_size)
	var y = floor((world_pos.y - offset.y) / tile_size)
	return Vector2(x, y)


## Convert a tile position to a world position
func TileToWorldPos(tile_pos):
	var tile_size = cell_quadrant_size
	var offset = get_used_rect().position * tile_size
	var x = tile_pos.x * tile_size + offset.x
	var y = tile_pos.y * tile_size + offset.y
	return Vector2(x, y)
