extends Resource
class_name Weapons

@export var name : String = ""
@export_range(0, 20) var short_range : int = 0
@export_range(0, 72) var long_range : int = 0
@export var bonus_to_hit_short : int = 0
@export var bonus_to_hit_long : int = 0
@export var strength : int = 0
@export var damage : int = 0
@export var save_modifier : int = 0

#Type being renamed as Special
@export var special_combat : bool = false
@export var special_heavy : float = 0.0
@export var special_slow : bool = false
@export var special_follow : bool = false
@export var area : float = 0.0
