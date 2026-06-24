class_name HabilityHandler
extends Node

var habilities: Array[Hability]:
	get:
		var res: Array[Hability]
		for child in get_children():
			if child is Hability:
				res.append(child)
		return res
