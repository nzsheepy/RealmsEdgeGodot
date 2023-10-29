extends TileMap
class_name Grid

enum { INVALID = -1, GRASS = 0, TREE = 1, MOUNTAIN = 2 }

var tiles

# Called when the node enters the scene tree for the first time.
func _init():
	_buildTiles()


func _buildTiles():
	var atlasSource: TileSetAtlasSource = tile_set.get_source(3)
	var pos = get_used_rect().position
	var size = get_used_rect().size

	# Fill empty tiles 2d array with -1
	tiles = []
	for y in range(0, size.y):
		tiles.append([])
		for x in range(0, size.x):
			tiles[y].append(INVALID)

	var grassTile : TileData = atlasSource.get_tile_data(Vector2i(0, 0), 0)
	var treeTile : TileData = atlasSource.get_tile_data(Vector2i(1, 0), 0)
	var mountainTile : TileData = atlasSource.get_tile_data(Vector2i(2, 0), 0)

	for tile in get_used_cells(0):
		var y = tile.y - pos.y
		var x = tile.x - pos.x
		var tileData = get_cell_tile_data(0, tile)

		if tileData == null:
			continue

		if tileData == grassTile:
			tiles[y][x] = GRASS
		elif tileData == treeTile:
			tiles[y][x] = TREE
		elif tileData == mountainTile:
			tiles[y][x] = MOUNTAIN


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
