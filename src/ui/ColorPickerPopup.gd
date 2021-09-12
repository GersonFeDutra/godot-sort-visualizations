tool
extends Control

var is_showing: bool = false
onready var anchor_point: Control = $AnchorPoint
onready var color_picker_popup: Popup = $AnchorPoint/Popup
onready var color_picker_container: MarginContainer = $AnchorPoint/Popup/MarginContainer
onready var color_picker: ColorPicker = $AnchorPoint/Popup/MarginContainer/ColorPicker


func _ready() -> void:
	
	if rect_min_size < $Button.rect_size:
		rect_min_size = $Button.rect_size


func _on_Button_pressed() -> void:
	
	if not is_showing:
		color_picker_popup.popup()


func _on_Popup_popup_hide() -> void:
	is_showing = false


func _on_ColorPicker_preset_added(color: Color) -> void:
	color_picker_popup.rect_min_size = color_picker_container.rect_size
