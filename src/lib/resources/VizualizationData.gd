extends Resource

const TARGET_TRANS_SHADE: float = 0.66
export var expand_icon_path: NodePath
export var player_path: NodePath
export var overlay_path: NodePath
export var full_mode_player_path: NodePath
var hint: String
var icon_material: ShaderMaterial
var player: Node
var overlay: Control
var full_mode_player: AnimationPlayer


func start(at: Control, from: Control) -> void:
	icon_material = (at.get_node(expand_icon_path) as TextureRect).material
	overlay = at.get_node(overlay_path)
	player = at.get_node(player_path)
	full_mode_player = at.get_node(full_mode_player_path)
	hint = from.hint_tooltip
	Tools.resolve_connection(from, "colors_changed", self, "update_colors", [from])
	Tools.resolve_connection(from, "mouse_entered", overlay, "show")
	Tools.resolve_connection(from, "mouse_exited", overlay, "hide")
	Tools.resolve_connection(
				from, "visualization_clicked", self, "_on_Visualization_clicked", [at, from])
	Tools.resolve_connection(at, "full_mode_cancelled", self, "_on_full_mode_cancelled", [at, from])
	Tools.resolve_connection(player, "resized_in", self, "_on_Vizualization_resized_in", [at, from])
	Tools.resolve_connection(
			player, "resized_out", self, "_on_Vizualization_resized_out", [at, from])
	from.is_input_mode_external = true
	overlay.hide()
	update_colors(from)


func update_colors(from: Control) -> void:
	var new_color: Color = from.colors.base
	new_color = new_color.linear_interpolate(from.colors.multiply, TARGET_TRANS_SHADE)
	
	icon_material.set_shader_param("color", new_color)


func _on_full_mode_cancelled(at: Control, from: Control) -> void:
	at.set_process_input(false)
	player.resize(false)
	
	if from.settings.visible:
		from.toggle_controls_visibility()
	
	at.set_process_input(false)
	from.is_input_mode_external = true


func _on_Visualization_clicked(at: Control, from: Control) -> void:
	player.resize(true)
	at.highlight(from)
	at.set_process_input(true)


func _on_Vizualization_resized_in(at: Control, from: Control) -> void:
	full_mode_player.play("fade_out")
	from.is_input_mode_external = false
	from.hint_tooltip = ""
	at.set_process_unhandled_input(false)


func _on_Vizualization_resized_out(at: Control, from: Control) -> void:
	from.is_input_mode_external = true
	at.reset_highlight(from)
	from.hint_tooltip = hint
	at.set_process_unhandled_input(true)
