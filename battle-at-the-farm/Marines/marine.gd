extends CharacterBody2D

enum Stat{ M, WS, BS, S, T, W, I, A, Ld, Int, Cl, WP }
var stats := [4, 4, 4, 4, 3, 1, 4, 1, 8, 8, 8, 8]

@export var equipped_weapons: Array[Weapons] = []
@export var equipped_armor: Array[Armor] = []

func get_stat(stat_index: int) -> int:
	return stats[stat_index]
	
func get_movement_range() -> float:
	return stats[Stat.M] * 100  # Assuming 100 pixels = 1 inch scale

func _ready():
	pass
