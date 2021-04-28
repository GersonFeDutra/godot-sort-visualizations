tool
extends Control

signal visualization_clicked

enum IndexStates {
	NORMAL,
	CURRENT,
	WALL,
	PIVOT,
}

export var invert_red: bool setget set_invert_red
export var invert_green: bool setget set_invert_green
export var invert_blue: bool = true setget set_invert_blue

export (int, 1, 9999) var array_size: int = 5 setget set_array_size
export (float, .1, 1.0) var padding: float = .8 setget set_padding
export (float, .001, 1.0) var animation_step_frequency: float = .07

export var color_multiply: Color = Color(1.0, .5, 1.0) setget set_color_multiply
export var color_base: Color = Color(1.0, 1.0, .9) setget set_color_base
export var left_wall_color: Color = Color.slateblue setget set_left_wall_color
export var current_marker_color: Color = Color.tomato setget set_current_marker_color
export var pivot_color: Color = Color.aquamarine setget set_pivot_color

var is_padding_enabled: bool = true
var is_animation_killed: bool
var is_input_mode_external: bool setget set_is_input_mode_external

var array: PoolIntArray
var states_array: PoolIntArray
var rng := RandomNumberGenerator.new()

onready var animation_seed: int = rng.seed
onready var labels_container: VBoxContainer = $LabelsVBoxContainer
onready var settings_container: VBoxContainer = $SettingsVBoxContainer
onready var step_timer: Timer = $StepTimer


func _ready() -> void:
	rng.randomize()
	$SettingsVBoxContainer/HBoxContainer/BaseColorPickerPopup/Popup/ColorPicker.color = color_base
	$SettingsVBoxContainer/HBoxContainer/MultiplyColorPickerPopup/Popup/ColorPicker.color = \
			color_multiply
	$SettingsVBoxContainer/HBoxContainer/WallColorPickerPopup/Popup/ColorPicker.color = \
			left_wall_color
	$SettingsVBoxContainer/HBoxContainer/MarkerPickerPopup/Popup/ColorPicker.color = \
			current_marker_color
	$SettingsVBoxContainer/HBoxContainer/PivotPickerPopup/Popup/ColorPicker.color = pivot_color
	$SettingsVBoxContainer/HBoxContainer2/RedCheckButton.pressed = invert_red
	$SettingsVBoxContainer/HBoxContainer2/GreenCheckButton.pressed = invert_green
	$SettingsVBoxContainer/HBoxContainer2/BlueCheckButton.pressed = invert_blue
	$SettingsVBoxContainer/HBoxContainer2/SpeedHBoxContainer/HSlider.value = step_timer.wait_time
	$SettingsVBoxContainer/HBoxContainer/SpinBox.value = array_size
	$SettingsVBoxContainer/HBoxContainer/PaddingCheckButton.pressed = is_padding_enabled
	start()


func _draw() -> void:
	var line_width: float = rect_size.x / array_size
	var current_x: float = line_width / 2.0
	
	for i in array.size():
		var height: int = array[i]
		var size_range := height as float / array_size as float
		var color: Color
		
		match states_array[i]:
			IndexStates.NORMAL:
				color = color_multiply * Color(
					_invert_float(invert_red, size_range * color_base.r),
					_invert_float(invert_green, size_range * color_base.g),
					_invert_float(invert_blue, size_range * color_base.b))
			IndexStates.CURRENT:
				color = current_marker_color
			IndexStates.WALL:
				color = left_wall_color
			IndexStates.PIVOT:
				color = pivot_color
		
		draw_line(Vector2(current_x,  rect_size.y),
				Vector2(current_x, rect_size.y - rect_size.y * size_range),
				color, line_width * padding if is_padding_enabled else line_width)
		current_x += line_width


func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_accept"):
		restart()
		get_tree().set_input_as_handled()


func _on_RedCheckButton_toggled(button_pressed: bool) -> void:
	invert_red = button_pressed
	update()


func _on_BlueCheckButton_toggled(button_pressed: bool) -> void:
	invert_blue = button_pressed
	update()


func _on_GreenCheckButton_toggled(button_pressed: bool) -> void:
	invert_green = button_pressed
	update()


func _on_PaddingCheckButton_toggled(button_pressed: bool) -> void:
	is_padding_enabled = button_pressed
	update()


func _on_HSlider_value_changed(value: float) -> void:
	animation_step_frequency = value
	step_timer.wait_time = animation_step_frequency


func _on_ColorPicker_color_changed(color: Color) -> void:
	self.color_base = color
	update()


func _on_ColorPickerMultiply_color_changed(color: Color) -> void:
	self.color_multiply = color
	update()


func _on_WallColorPicker_color_changed(color: Color) -> void:
	left_wall_color = color
	update()


func _on_MarkerColorPicker_color_changed(color: Color) -> void:
	current_marker_color = color
	update()


func _on_PivotColorPicker_color_changed(color: Color) -> void:
	pivot_color = color
	update()


func _on_Visualization_gui_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("click"):
		
		if not is_input_mode_external:
			labels_container.visible = not labels_container.visible
			settings_container.visible = not settings_container.visible
		
		emit_signal("visualization_clicked")


func start() -> void:
	var tmp: int = array_size
	self.array_size = 0 # Limpa os valores anterioers do array.
	rng.seed = animation_seed # Reseta o gerador de números.
	self.array_size = tmp
	
	if not Engine.is_editor_hint():
		var answer = _process_visualization()
		
		if answer is GDScriptFunctionState:
			yield(answer, "completed")
		
		is_animation_killed = false


func _process_visualization():
	pass


func restart():
	is_animation_killed = true
	step_timer.emit_signal("timeout")
	
	yield(get_tree().create_timer(animation_step_frequency), "timeout")
	is_animation_killed = false
	start()



static func _invert_float(invert: bool, n: float) -> float:
	return 1.0 - n if invert else n


func set_is_input_mode_external(value: bool) -> void:
	is_input_mode_external = value
	set_process_unhandled_input(not value)


func set_array_size(value: int) -> void:
	array_size = value
	states_array.resize(array_size)
	
	if array.size() == array_size:
		return
	
	array.resize(array_size)
	
	for i in array_size:
		array[i] = rng.randi() % array_size + 1
		states_array[i] = IndexStates.NORMAL
	
	update()


func set_padding(value: float) -> void:
	padding = value
	update()


func set_color_multiply(value: Color) -> void:
	color_multiply = value
	update()


func set_color_base(value: Color) -> void:
	color_base = value
	update()


func set_left_wall_color(value: Color) -> void:
	left_wall_color = value
	update()


func set_current_marker_color(value: Color) -> void:
	current_marker_color = value
	update()


func set_pivot_color(value: Color) -> void:
	pivot_color = value
	update()


func set_invert_red(value) -> void:
	invert_red = value
	update()


func set_invert_green(value) -> void:
	invert_green = value
	update()


func set_invert_blue(value) -> void:
	invert_blue = value
	update()


func _on_SpinBox_value_changed(value: float) -> void:
	
	is_animation_killed = true
	step_timer.emit_signal("timeout")
	
	yield(get_tree().create_timer(animation_step_frequency), "timeout")
	is_animation_killed = false
	array_size = value as int
	start()
