## Iterador personalitzat per recórrer una regió bidimensional de cel·les.
##
## Permet l'ús d'estructures 'for' per visitar cada coordenada Vector2i 
## dins d'un rectangle definit entre un punt d'inici i un punt final.
extends RefCounted
class_name Vector2iIterator

var _start: Vector2i
var _current: Vector2i
var _end: Vector2i

## Inicialitza l'iterador amb els límits de la regió.
## [br][br][b]Paràmetres:[/b]
## [br]- [param p_start]: La coordenada inicial (inclusiva).
## [br]- [param p_end]: La coordenada final (inclusiva).
func _init(start: Vector2i, stop: Vector2i):
	self._start = start
	self._current = start
	self._end = Vector2i(stop.x + 1, stop.y +1)

func should_continue() -> bool:
	return (_current.y < _end.y)

func _iter_init(_arg) -> bool:
	_current = _start
	return should_continue()

func _iter_next(_arg) -> bool:
	_current.x += 1
	if _current.x == _end.x:
		_current.x = _start.x
		_current.y += 1
	return should_continue()

func _iter_get(_arg) -> Vector2i:
	return _current