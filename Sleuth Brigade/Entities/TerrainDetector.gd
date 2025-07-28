extends Area2D

@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var footsteps := $Footstep

var current_tilemap : TileMap
var terrain_mask : StringName

func _ready():
	body_shape_entered.connect(on_entered)
	if get_parent().is_in_group("player"): footsteps.max_distance = 2000
	else: footsteps.max_distance = 750

func on_entered(body_rid : RID, body : Node2D, _body_shape_index : int, _local_shape_index : int):
	if body is TileMap:
		get_collision(body,body_rid)

func get_collision(body : Node2D, body_rid : RID):
	current_tilemap = body
	var tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)
	
	for index in current_tilemap.get_layers_count():
		var tile_data = current_tilemap.get_cell_tile_data(index,tile_coords)
		if !tile_data is TileData:
			continue
		if tile_data.get_custom_data_by_layer_id(0) != "": terrain_mask = tile_data.get_custom_data_by_layer_id(0)
		if terrain_mask == &"water" && get_parent().airborne == false: get_parent().in_water()
		if get_parent().terrain != terrain_mask:
			get_parent().terrain = terrain_mask
