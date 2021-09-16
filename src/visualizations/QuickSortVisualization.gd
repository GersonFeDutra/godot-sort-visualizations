tool
extends "res://src/Visualization.gd"


func _process_visualization():
	quick_sort(0, array_size - 1)

func quick_sort(start: int, end: int):
	
	if start < end:
		
		var answer
		var pivot_index = yield(partition(start, end), "completed")
		
		if is_animation_killed:
			return
		
		quick_sort(start, pivot_index - 1)
		
		if is_animation_killed:
			return
		
		answer = quick_sort(pivot_index + 1, end)
		
		if answer is GDScriptFunctionState:
			yield(answer, "completed")
		
		if is_animation_killed:
			return


func partition(start: int, end: int) -> int:
	var pivot_value: int = array[end]
	var left_wall: int = start
	states_array[end] = IndexStates.PIVOT
	
	for i in range(start, end):
		
		states_array[i] = IndexStates.CURRENT
		states_array[left_wall] = IndexStates.WALL
		
		if array[i] < pivot_value:
			yield(swap(i, left_wall), "completed")
			
			if is_animation_killed:
				return
			
			states_array[left_wall] = IndexStates.NORMAL
			left_wall += 1
		
		step_timer.start()
		yield(step_timer, "timeout")
		
		if is_animation_killed:
			return
		
		update()
		states_array[i] = IndexStates.NORMAL
		states_array[left_wall] = IndexStates.NORMAL
	
	yield(swap(left_wall, end), "completed")
	
	if is_animation_killed:
		return
	
	states_array[end] = IndexStates.NORMAL
	
	return left_wall


func swap(a: int, b: int) -> void:
	var tmp: int = array[a]
	array[a] = array[b]
	array[b] = tmp
	step_timer.start()
	yield(step_timer, "timeout")
	
	if is_animation_killed:
		return
	
	update()
