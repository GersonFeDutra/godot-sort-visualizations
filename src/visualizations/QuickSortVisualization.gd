tool
extends "res://src/Visualization.gd"

# WATCH (desafio) -> Implementar com base nas funcionalidades do yield
var processes_counter: int = 0 setget set_process_counter


func _process_visualization() -> void:
	self.processes_counter += 1
	yield(quick_sort(0, array_size - 1), "completed")
	self.processes_counter -= 1


func quick_sort(start: int, end: int):
	self.processes_counter += 1
	
	if start < end:
		
		var answer
		self.processes_counter += 1
		var pivot_index = yield(partition(start, end), "completed")
		self.processes_counter -= 1
		
		if is_animation_killed:
			return
		
		quick_sort(start, pivot_index - 1)
		
		if is_animation_killed:
			return
		
		answer = quick_sort(pivot_index + 1, end)
		
		if answer is GDScriptFunctionState:
			self.processes_counter += 1
			yield(answer, "completed")
			self.processes_counter -= 1
		
		if is_animation_killed:
			return
	
	self.processes_counter -= 1


func partition(start: int, end: int) -> int:
	self.processes_counter += 1
	
	var pivot_value: int = array[end]
	var left_wall: int = start
	states_array[end] = IndexStates.PIVOT
	
	for i in range(start, end):
		
		states_array[i] = IndexStates.CURRENT
		states_array[left_wall] = IndexStates.WALL
		
		if array[i] < pivot_value:
			self.processes_counter += 1
			yield(swap(i, left_wall), "completed")
			self.processes_counter -= 1
			
			if is_animation_killed:
				return
			
			states_array[left_wall] = IndexStates.NORMAL
			left_wall += 1
		
		step_timer.start()
		self.processes_counter += 1
		yield(step_timer, "timeout")
		self.processes_counter -= 1
		
		if is_animation_killed:
			return
		
		update()
		states_array[i] = IndexStates.NORMAL
		states_array[left_wall] = IndexStates.NORMAL
	
	self.processes_counter += 1
	yield(swap(left_wall, end), "completed")
	self.processes_counter -= 1
	
	if is_animation_killed:
		return
	
	states_array[end] = IndexStates.NORMAL
	
	self.processes_counter -= 1
	return left_wall


func swap(a: int, b: int) -> void:
	self.processes_counter += 1
	
	var tmp: int = array[a]
	array[a] = array[b]
	array[b] = tmp
	step_timer.start()
	self.processes_counter += 1
	yield(step_timer, "timeout")
	self.processes_counter -= 1
	
	if is_animation_killed:
		return
	
	update()
	self.processes_counter -= 1


func set_process_counter(value: int) -> void:
	processes_counter = value
	
	if processes_counter == 0:
		emit_signal("visualization_finished")
