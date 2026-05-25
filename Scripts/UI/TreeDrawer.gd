extends Node2D
class_name TreeDrawer

# Aixo son proves per fer una especie de UI amb una estetica d'arbre fractal

@export var color: Color
@export var max_angle: float = deg_to_rad(22.5):
	set(value):
		max_angle = deg_to_rad(value)
		print("Setted angle to %s" % max_angle)

var _polygons : Array[PackedVector2Array] = []
var rng := RandomNumberGenerator.new()

class WightedPoint:
	var center: Vector2
	var width: float

class Branch:
	var p1: Vector2
	var p2: Vector2
	var origin: Vector2:
		get:
			return p1.lerp(p2, 0.5)
	var dest1:Vector2
	var dest2: Vector2
	func _init() -> void:
		pass
	
	func AsPolygon() -> PackedVector2Array:
		return PackedVector2Array([
			p1,
			p2,
		])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	var next:= Vector2(153, -130)
	_create_line(
		Vector2(48, -82),
		Vector2(47, -103),
		next
	)
	_tree_from_point(next)

func _draw() -> void:
	for poly in _polygons:
		draw_colored_polygon(poly, color)

func _create_next_line(point: Vector2):
	var points := _polygons[-1]
	var p1 := points[0]
	var p2 := points[-1]
	_create_line(p1, p2, point)

func _create_line(p1: Vector2, p2: Vector2, point: Vector2):
	var amplitude := p1.distance_to(p2)
	var new_amplitude := 1 - rng.randf_range(amplitude /2, amplitude) / amplitude
	var mid := _midpoint(p1, p2)
	var dist := point - mid
	var next1 := p1.lerp(p2, new_amplitude) + dist
	var next2 := p2.lerp(p1, new_amplitude) + dist
	var polygon:= PackedVector2Array()
	polygon.append_array([
		next1,
		p1,
		p2,
		next2
	])
	polygon.append(next2)
	_polygons.append(polygon)

func _tree_from_point(new_point: Vector2):
	var points := _polygons[-1]
	var p1 := points[0]
	var p2 := points[-1]
	var mid := _midpoint(p1, p2)
	var distance := mid.distance_to(new_point)
	_create_next_line(new_point)
	_branch(new_point, distance, false)
	_branch(new_point, distance, true)

func _branch(origin: Vector2, max_distance: float, negative: bool) -> void:
	var distance := rng.randf_range(0, max_distance)
	if distance < 15:
		return
	var ang := _gen_angle(negative)
	var offset := Vector2(
		cos(ang),
		sin(ang)
	) * distance
	var new_point := offset + origin
	_create_next_line(new_point)
	_branch(new_point, distance, false)
	_branch(new_point, distance, true)

func _gen_angle(negative: bool) -> float:
	var max_ang := max_angle
	if negative:
		max_ang *= -1
	var min_ang := max_ang * 0.2
	return rng.randf_range(min_ang, max_ang)

func _midpoint(p1: Vector2, p2: Vector2) -> Vector2:
	return Vector2(
		(p1.x + p2.x) / 2,
		(p1.y + p2.y) / 2,
	)
