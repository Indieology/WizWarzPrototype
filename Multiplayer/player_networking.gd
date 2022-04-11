extends Node

var sync_position : Vector2:
	set(value):
		sync_position = value
		processed_position = false
var sync_velocity : Vector2

var sync_character_h_flip : bool
var sync_character_animation : String
var sync_character_projectile_detector : Vector2

var processed_position : bool
