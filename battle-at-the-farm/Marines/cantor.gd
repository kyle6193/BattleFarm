extends CharacterBody2D

enum Stat{ M, WS, BS, S, T, W, I, A, Ld, Int, Cl, WP }
var stats := [4, 6, 6, 4, 4, 3, 6, 3, 9, 9, 9, 9]

@export var equipped_weapons: Array[Weapons] = []
@export var equipped_armor: Array[Armor] = []

func get_stat(stat_index: int) -> int:
	return stats[stat_index]
	
func _ready():
	pass
