extends Resource
class_name BaseStats

## Gestiona les estadístiques base dels personatges.
##
## Aquest recurs defineix els atributs principals com la moral, la salut,
## la resistència i les capacitats ofensives o defensives.

## [b]Moral[/b]: Afecta l'efectivitat dels atacs. 
## Augmenta la [member dexterity], la [member attack] i la [member precision].
@export var morale: int = 10

## [b]Vida[/b]: Punts de salut actuals del jugador.
@export var vitality: int = 10

## [b]Resistència[/b]: Capacitat per disminuir el dany rebut.
@export var resistance: int = 10

## [b]Força[/b]: Determina el dany realitzat en atacs cos a cos.
@export var force: int = 10

## [b]Destresa[/b]: Influeix en la velocitat de moviment i la probabilitat d'esquivar atacs.
@export var dexterity: int = 10

## [b]Precisió[/b]: Probabilitat d'encertar i fer dany amb atacs a distància.
@export var precision: int = 10