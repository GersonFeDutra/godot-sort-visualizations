tool
extends "res://src/Visualization.gd"


func _process_visualization() -> GDScriptFunctionState:
	return insertion_sort(array_size)


func insertion_sort(size: int) -> GDScriptFunctionState:
	
	for i in size:
		var j: int = i
		states_array[i] = IndexStates.CURRENT
		
		while j > 0 and array[j - 1] > array[j]:
			var swap: int = array[j]
			array[j] = array[j - 1]
			array[j - 1] = swap
			
			states_array[j] = IndexStates.PIVOT
			states_array[j - 1] = IndexStates.WALL
			step_timer.start()
			yield(step_timer, "timeout")
			
			if is_animation_killed:
				return null
			
			update()
			states_array[j] = IndexStates.NORMAL
			states_array[j - 1] = IndexStates.NORMAL
			j -= 1
		
		states_array[i] = IndexStates.NORMAL
	
	return null
