tool
extends Control

onready var color_picker_popup: Popup = $Popup


func _ready() -> void:
	
	if rect_min_size < $Button.rect_size:
		rect_min_size = $Button.rect_size


func _on_Button_toggled(button_pressed: bool) -> void:
	
	if button_pressed:
		color_picker_popup.popup()
	else:
		color_picker_popup.hide()
