tool
extends ColorPickerButton
class_name CustomColorPickerButton

const GIZMO_SIZE := Vector2.ONE * 16
var visual_tool := VisualTools.new(self)
export var offset: Vector2 setget set_offset


func _ready() -> void:
	
	if Engine.is_editor_hint():
		visual_tool.add_visual_tips(
				visual_tool.VisualTips.GIZMO, GIZMO_SIZE, Color.darkseagreen, offset)
	else:
		Tools.resolve_connection(self, "picker_created", self, "_on_Picker_created")
	


func _on_Picker_created() -> void:
	var popup: PopupPanel = get_children()[get_child_count() - 1]
	Tools.resolve_connection(popup, "about_to_show", self, "_on_Popup_about_to_show", [popup])


func _on_Popup_about_to_show(popup: PopupPanel) -> void:
	popup.rect_position = rect_global_position + offset


func _update_visual_tip() -> void:
	visual_tool.tip_positions[0] = offset


func set_offset(value: Vector2) -> void:
	offset = value
	
	if Engine.is_editor_hint():
		call_deferred("_update_visual_tip")
