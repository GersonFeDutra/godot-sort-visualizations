tool
extends Node2D
class_name VisualTools

enum VisualTips {
	SQUARE,
	CIRCLE,
	GIZMO,
}
var visual_tips := PoolIntArray()
var tip_sizes := PoolVector2Array() setget set_tip_sizes
var tip_positions := PoolVector2Array() setget set_tip_positions
var tip_colors := PoolColorArray() setget set_tip_colors


func _init(target_parent: Node, identifier: String = "EditorTools") -> void:
	
	name = identifier
	target_parent.add_child(self)


func _draw() -> void:
	
	for i in visual_tips.size():
		
		match visual_tips[i]:
			
			VisualTips.SQUARE:
				draw_rect(Rect2(tip_positions[i], tip_sizes[i]), tip_colors[i])
			
			VisualTips.CIRCLE:
				draw_circle(tip_positions[i], tip_sizes[i].x, tip_colors[i])
			
			VisualTips.GIZMO:
				var half_size: Vector2 = tip_sizes[i] / 2
				draw_line(Vector2(tip_positions[i].x - half_size.x, tip_positions[i].y),
						Vector2(tip_positions[i].x + half_size.x, tip_positions[i].y), tip_colors[i])
						
				draw_line(Vector2(tip_positions[i].x, tip_positions[i].y - half_size.y),
						Vector2(tip_positions[i].x, tip_positions[i].y + half_size.y), tip_colors[i])


func add_visual_tips(type: int, size: Vector2, color: Color, pos: Vector2 = Vector2.ZERO) -> void:
	visual_tips.append(type)
	tip_sizes.append(size)
	tip_colors.append(color)
	tip_positions.append(pos)
	update()


func clean_visual_tips() -> void:
	visual_tips = []
	tip_sizes = []
	tip_colors = []
	tip_positions = []
	update()


func set_tip_sizes(value: PoolVector2Array) -> void:
	tip_sizes = value
	update()


func set_tip_positions(value: PoolVector2Array) -> void:
	tip_positions = value
	update()


func set_tip_colors(value: PoolColorArray) -> void:
	tip_colors = value
	update()
