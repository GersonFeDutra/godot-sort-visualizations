extends Node

onready var label_animation_player: AnimationPlayer = $FullModeLabel/AnimationPlayer
var was_displayer_showed_once: bool


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("full_mode_toggle"):
		OS.window_fullscreen = not OS.window_fullscreen
		
		if not was_displayer_showed_once:
			label_animation_player.play("fade_out")
			was_displayer_showed_once = true
