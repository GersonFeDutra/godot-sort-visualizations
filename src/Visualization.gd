tool
extends Control

signal visualization_clicked

enum IndexStates {
	NORMAL,
	CURRENT,
	WALL,
	PIVOT,
}

export var is_padding_enabled: bool = true setget set_is_padding_enabled
export (int, 1, 9999) var array_size: int = 5 setget set_array_size
export (float, .1, 1.0) var padding: float = .8 setget set_padding
export (float, .001, 1.0) var animation_speed: float = \
		.5 setget set_animation_speed
export(float, EASE) var speed_easing: float = 0.2

export var colors: Dictionary = {
	multiply = Color(1.0, .5, 1.0),
	base = Color(1.0, 1.0, .9),
	wall = Color.slateblue,
	marker = Color.tomato,
	pivot = Color.aquamarine,
} setget set_colors
export var invert_shades: Dictionary = {
	red = false,
	green = false,
	blue = true,
} setget set_invert_shades


var is_animation_killed: bool
var is_input_mode_external: bool setget set_is_input_mode_external

var array: PoolIntArray
var states_array: PoolIntArray
var rng := RandomNumberGenerator.new()

onready var animation_seed: int = rng.seed
onready var labels_container: VBoxContainer = $LabelsVBoxContainer
onready var step_timer: Timer = $StepTimer
onready var settings: VBoxContainer = $Settings


func _ready() -> void:
	rng.randomize()
	
	for key in colors.keys():
		settings.color_pickers[key].color = colors[key]
	
	for key in invert_shades.keys():
		settings.check_buttons[key].pressed = invert_shades[key]
	
	settings.speed_slider.value = animation_speed
	step_timer.wait_time = 1.0 - ease(animation_speed, speed_easing)
	settings.columns_spin_box.value = array_size
	settings.padding_button.pressed = is_padding_enabled
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
				color = colors.multiply * Color(
					_invert_float(invert_shades.red, size_range * colors.base.r),
					_invert_float(invert_shades.green, size_range * colors.base.g),
					_invert_float(invert_shades.blue, size_range * colors.base.b))
			IndexStates.CURRENT:
				color = colors.marker
			IndexStates.WALL:
				color = colors.wall
			IndexStates.PIVOT:
				color = colors.pivot
		
		draw_line(Vector2(current_x,  rect_size.y),
				Vector2(current_x, rect_size.y - rect_size.y * size_range),
				color, line_width * padding if is_padding_enabled else line_width)
		current_x += line_width


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_accept"):
		restart()
		get_tree().set_input_as_handled()


func start() -> void:
	if Engine.is_editor_hint():
		return
	
	var tmp: int = array_size
	self.array_size = 0 # Limpa os valores anterioers do array.
	rng.seed = animation_seed # Reseta o gerador de números.
	self.array_size = tmp
	var answer = _process_visualization()
	
	if answer is GDScriptFunctionState:
		yield(answer, "completed")
	
	is_animation_killed = false


# @virtual
func _process_visualization():
	pass


func restart():
	is_animation_killed = true
	step_timer.emit_signal("timeout")
	
	yield(get_tree().create_timer(1.0 - ease(animation_speed, speed_easing)), "timeout")
	is_animation_killed = false
	start()


static func _invert_float(invert: bool, n: float) -> float:
	return 1.0 - n if invert else n


func _update_padding_button() -> void:
	settings.padding_button.pressed = is_padding_enabled


func set_is_input_mode_external(value: bool) -> void:
	is_input_mode_external = value
	set_process_input(not value)


func set_is_padding_enabled(value: bool) -> void:
	is_padding_enabled = value
	call_deferred("update")
	
	if Engine.is_editor_hint():
		call_deferred("_update_padding_button")


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
	call_deferred("update")


func _update_speed() -> void:
	settings.speed_slider.value = animation_speed
	step_timer.wait_time = 1.0 - ease(animation_speed, speed_easing)


func set_animation_speed(value: float) -> void:
	animation_speed = value
	call_deferred("_update_speed")


func _update_colors() -> void:

	for key in colors.keys():
		settings.color_pickers[key].color = colors[key]


func set_colors(value: Dictionary) -> void:
	colors = value
	call_deferred("update")
	
	if Engine.is_editor_hint():
		call_deferred("_update_colors")


func _update_buttons() -> void:

	for key in invert_shades.keys():
		settings.check_buttons[key].pressed = invert_shades[key]


func set_invert_shades(value: Dictionary) -> void:
	invert_shades = value
	call_deferred("update")
	
	if Engine.is_editor_hint():
		call_deferred("_update_buttons")


func _on_Visualization_gui_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("click"):
		
		if not is_input_mode_external:
			labels_container.visible = not labels_container.visible
			settings.visible = not settings.visible
		
		emit_signal("visualization_clicked")


func _on_Settings_color_changed(slot: String, color: Color) -> void:
	colors[slot] = color
	update()


func _on_Settings_button_toggled(slot: String, was_pressed: bool) -> void:
	invert_shades[slot] = was_pressed
	update()


func _on_Settings_columns_changed(to: float) -> void:
	is_animation_killed = true
	step_timer.emit_signal("timeout")
	
	yield(get_tree().create_timer(animation_speed), "timeout")
	is_animation_killed = false
	array_size = to as int
	start()


func _on_Settings_speed_changed(to: float) -> void:
	animation_speed = to
	step_timer.wait_time = 1.0 - ease(animation_speed, speed_easing)


func _on_Settings_use_padding_toggled(was_enabled: bool) -> void:
	is_padding_enabled = was_enabled
	update()
