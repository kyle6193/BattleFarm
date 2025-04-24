# This script extends the CharacterBody2D class, which is used for 2D characters with physics-based movement.

# The Stat enum defines various attributes for the character, such as Movement (M), Weapon Skill (WS), Ballistic Skill (BS), etc.
# These attributes are stored in the `stats` array, where each index corresponds to a specific attribute defined in the enum.

# The `stats` array holds the values for each attribute. For example, the first value (4) represents the Movement (M) stat.
# Movement (M) determines how far the character can move in a turn, measured in inches.

# The `equipped_weapons` and `equipped_armor` variables are exported, allowing them to be set in the Godot editor.
# These arrays store the weapons and armor currently equipped by the character.

# The `get_stat` function retrieves the value of a specific stat based on its index in the `stats` array.
# For example, calling `get_stat(Stat.M)` will return the Movement stat value.

# The `_ready` function is called when the node is added to the scene. Currently, it does nothing but can be used for initialization.

# The `get_movement_range` function calculates the character's movement range in pixels.
# It multiplies the Movement (M) stat by 100, assuming a scale of 100 pixels per inch.
# This function is useful for determining how far the character can move in a turn.

extends CharacterBody2D

enum Stat{ M, WS, BS, S, T, W, I, A, Ld, Int, Cl, WP }
var stats := [4, 4, 4, 4, 4, 1, 3, 1, 7, 6, 7, 7]

@export var equipped_weapons: Array[Weapons] = []
@export var equipped_armor: Array[Armor] = []

func get_stat(stat_index: int) -> int:
	return stats[stat_index]
	
func _ready():
	pass

func get_movement_range() -> float:
	return stats[Stat.M] * 100  # Assuming 100 pixels = 1 inch scale
