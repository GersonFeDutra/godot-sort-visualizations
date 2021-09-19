extends Control

const REC: String = "rec"
var is_recording: bool setget set_is_recording
var stop_at: int = 0
onready var recorder: ScreenRecorder = $ScreenRecorder
onready var bottom_bar: CenterContainer = $BottomBar
onready var wait_label: Label = $WaitLabel
onready var viewport: Viewport = $ViewportContainer/Viewport
onready var vizualizations: Control = $ViewportContainer/Viewport/Visualizations


func _ready() -> void:
	var event := InputEventKey.new()
	event.scancode = KEY_R
	InputMap.add_action(REC)
	InputMap.action_add_event(REC, event)


func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed(REC):
		
		if not Input.is_key_pressed(KEY_SHIFT):
			vizualizations.restart()
		
		self.is_recording = not is_recording
		get_tree().set_input_as_handled()


func set_is_recording(value: bool) -> void:
	is_recording = value
	
	if value:
		recorder.start(viewport)
	else:
		recorder.stop()


func _on_BottomBar_finish_mode_changed(to: int) -> void:
	stop_at = to


func _on_Visualizations_visualization_finished(wich: int) -> void:
	
	if wich == stop_at and is_recording:
		wait_label.show()
		self.is_recording = false


func _on_ScreenRecorder_process_completed(output_path: String) -> void:
	wait_label.hide()
	
	if OS.shell_open(output_path.get_base_dir()) != OK:
		push_error("Wouldn't able to open directory.")
		return
	
	if OS.shell_open(output_path) != OK:
		push_error("Wouldn't able to open file.")
