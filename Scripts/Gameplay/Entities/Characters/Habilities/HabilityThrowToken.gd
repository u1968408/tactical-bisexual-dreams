extends Hability

@export var token_model: Token
@export var marker_object: Marker3D
@export var path: Path3D
@export var path_follow: PathFollow3D

var _token: Token
var _marker_token: Marker3D


func _ready() -> void:
	path.reparent(board)
	token_model.visible = false
	token_model.monitorable = false
	path.visible = true


func cancel() -> void:
	if _token:
		_token.queue_free()
	super()


func clicked_tile(tile: Tile):
	generator = null
	InputController.can_interact = false
	character.look_at_direction(tile.global_position)
	character.current_state = Entity.EntityState.THROW

func on_hability_animation(animation_name: String):
	if animation_name == "throw":
		_token.throw_along_path(path_follow)


func on_tile_hover(tile: Tile):
	if tile == null or _token == null:
		path.visible = false
		return
	character.look_at_direction(tile.global_position)
	path.visible = true
	var direction: Vector3 = tile.global_position - character.global_position
	direction.y = 0
	direction = direction.normalized()
	direction.y = 1
	var distance: float = _marker_token.global_position.distance_to(tile.global_position)
	var out: Vector3 = direction * distance * 3 / 5
	path.curve.set_point_position(0, _marker_token.global_position)
	path.curve.set_point_out(0, out)
	path.curve.set_point_position(1, tile.global_position)


func _execute() -> void:
	if _marker_token == null:
		_create_marker()
	_token = token_model.create_from_character(character)
	_token.finished_travel.connect(_on_finished_travel)


func _on_finished_travel():
	_token.finished_travel.disconnect(_on_finished_travel)
	_token = null
	InputController.can_interact = true
	finished.emit(true)


func _create_marker():
	_marker_token = marker_object.duplicate()
	character.add_child(_marker_token)
	_marker_token.position = marker_object.position
