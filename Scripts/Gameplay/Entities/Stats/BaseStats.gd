class_name BaseStats
extends Resource

signal stats_changed

## Gestiona les estadístiques base dels personatges.
##
## Aquest recurs defineix els atributs principals com la moral, la salut,
## la resistència i les capacitats ofensives o defensives.

## [b]Moral[/b]: Afecta l'efectivitat dels atacs.
## Augmenta la [member dexterity], la [member attack] i la [member precision].
@export var morale: int:
	get:
		return _morale
	set(value):
		_morale = value
		stats_changed.emit()

## [b]Vida[/b]: Punts de salut actuals del jugador.
@export var vitality: int:
	get:
		return _vitality
	set(value):
		_vitality = value
		stats_changed.emit()

## [b]Resistència[/b]: Capacitat per disminuir el dany rebut.
@export var resistance: int:
	get:
		return _resistance
	set(value):
		_resistance = value
		stats_changed.emit()

## [b]Força[/b]: Determina el dany realitzat en atacs cos a cos.
@export var force: int:
	get:
		return _force
	set(value):
		_force = value
		stats_changed.emit()

## [b]Destresa[/b]: Influeix en la velocitat de moviment i la probabilitat d'esquivar atacs.
@export var dexterity: int:
	get:
		return _dexterity
	set(value):
		_dexterity = value
		stats_changed.emit()

## [b]Precisió[/b]: Probabilitat d'encertar i fer dany amb atacs a distància.
@export var precision: int:
	get:
		return _precision
	set(value):
		_precision = value
		stats_changed.emit()

var _morale: int = 10
var _vitality: int = 10
var _resistance: int = 10
var _force: int = 10
var _dexterity: int = 10
var _precision: int = 10
