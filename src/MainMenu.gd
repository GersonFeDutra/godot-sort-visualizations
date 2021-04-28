extends Control

onready var quick_sort_visualization: Control = $HBoxContainer/QuickSortVisualization
onready var insertion_sort_visualization: Control = $HBoxContainer/InsertionSortVisualization
var is_visualization_focus: bool

onready var quick_s_vis_animation_player: AnimationPlayer = \
		$HBoxContainer/QuickSortVisualization/AnimationPlayer
onready var insertion_s_vis_animation_player: AnimationPlayer = \
		$HBoxContainer/InsertionSortVisualization/AnimationPlayer


func _ready() -> void:
	quick_sort_visualization.is_input_mode_external = true
	insertion_sort_visualization.is_input_mode_external = true
#
#	quick_sort_visualization.connect("visualization_clicked", self, "_visualization_clicked",
#			["quick"])
#	insertion_sort_visualization.connect("visualization_clicked", self, "_visualization_clicked",
#			["insertion"])


func _unhandled_input(event: InputEvent) -> void:

	if event.is_action_pressed("ui_accept") and not is_visualization_focus:
		quick_sort_visualization.restart()
		insertion_sort_visualization.restart()
		get_tree().set_input_as_handled()


#func visualization_clicked(sort: String) -> void:
#	$HBoxContainer.set_process(false)
#
#	match sort:
#		"quick":
#			quick_s_vis_animation_player.play("resize_visualization_in")
#		"insertion":
#			insertion_s_vis_animation_player.play("resize_visualization_in")
#
#
#func _on_visualization_resize_animation_finished(sort: String, is_full: bool) -> void:
#
#	match sort:
#		"quick":
#			quick_sort_visualization.is_input_mode_external = is_full
#			set_process_unhandled_input(not is_full)
#
#			insertion_sort_visualization.is_input_mode_external = true
#
#	if is_full:
#		$HBoxContainer/QuickSortVisualization/AnimationPlayer


func _on_QuickSortVisualization_mouse_entered() -> void:
	$HBoxContainer/QuickSortVisualization/CheckButton.show()


func _on_QuickSortVisualization_mouse_exited() -> void:
	$HBoxContainer/QuickSortVisualization/CheckButton.hide()


func _on_InsertionSortVisualization_mouse_entered() -> void:
	$HBoxContainer/InsertionSortVisualization/CheckButton.show()


func _on_InsertionSortVisualization_mouse_exited() -> void:
	$HBoxContainer/InsertionSortVisualization/CheckButton.hide()


func _on_CheckButton_toggled(button_pressed: bool, sort: String) -> void:
	
	match sort:
		"quick":
			if button_pressed:
				quick_s_vis_animation_player.play("resize_visualization_in")
				quick_sort_visualization.is_input_mode_external = false
				insertion_sort_visualization.hide()
			else:
				quick_s_vis_animation_player.play("resize_visualization_out")
		
		"insertion":
			if button_pressed:
				quick_sort_visualization.hide()
				insertion_s_vis_animation_player.play("resize_visualization_in")
				insertion_sort_visualization.is_input_mode_external = false
			else:
				insertion_s_vis_animation_player.play("resize_visualization_out")


func _on_resize_visualization_out(sort: String) -> void:
	
	match sort:
		"quick":
			insertion_sort_visualization.show()
			quick_sort_visualization.is_input_mode_external = true
			
		"insertion":
			quick_sort_visualization.show()
			insertion_sort_visualization.is_input_mode_external = true
