class_name PriorityQueue extends Object

## A priority queue implementation using a binary heap.

## Enum for heap type
enum HeapType { MIN_HEAP, MAX_HEAP }

## The type of heap to use
## Min-Heap: Smaller priorities are more important
## Max-Heap: Larger priorities are more important
##
## Undefined behavior for changing this after adding elements
@export var heap_type: HeapType = HeapType.MIN_HEAP

## Internal storage for the heap
var _heap: Array = []

## Check if the queue is empty
func is_empty() -> bool:
	return _heap.size() == 0

## Add an element with a priority
func enqueue(element: Variant, priority: float) -> void:
	# Check if the element already exists in the heap
	for i in range(_heap.size()):
		if _heap[i][1] == element:
			# If the existing priority is higher (or lower for MAX_HEAP), update it
			if (heap_type == HeapType.MIN_HEAP and _heap[i][0] > priority) or \
			   (heap_type == HeapType.MAX_HEAP and _heap[i][0] < priority):
				_heap[i] = [priority, element]
				_heapify()
			return
	# Add the new element to the heap
	_heap.append([priority, element])
	_bubble_up(_heap.size() - 1)

## Remove and return the element with the highest priority
func dequeue() -> Variant:
	if is_empty():
		return null  # Return null if the queue is empty
	# Swap the first and last elements, then remove the last (highest priority)
	_swap(0, _heap.size() - 1)
	var element = _heap.pop_back()
	_bubble_down(0)
	return element[1]  # Return the element, not the priority

## Peek at the element with the highest priority without removing it
func peek() -> Variant:
	if is_empty():
		return null  # Return null if the queue is empty
	return _heap[0][1]  # Return the element, not the priority

## Get the size of the queue
func size() -> int:
	return _heap.size()

## Get the content of the queue as a list (for debugging)
func get_queue() -> Array:
	return _heap

## Restore the heap property after an update
func _heapify() -> void:
	for i in range(int((_heap.size() - 2) / 2), -1, -1):
		_bubble_down(i)

## Bubble up the element at the given index
func _bubble_up(index: int) -> void:
	while index > 0:
		var parent = int((index - 1) / 2)
		if not _compare(_heap[index][0], _heap[parent][0]):
			break
		_swap(index, parent)
		index = parent

## Bubble down the element at the given index
func _bubble_down(index: int) -> void:
	var size = _heap.size()
	while true:
		var left = 2 * index + 1
		var right = 2 * index + 2
		var selected = index

		if left < size and _compare(_heap[left][0], _heap[selected][0]):
			selected = left
		if right < size and _compare(_heap[right][0], _heap[selected][0]):
			selected = right
		if selected == index:
			break
		_swap(index, selected)
		index = selected

## Swap two elements in the heap
func _swap(i: int, j: int) -> void:
	var temp = _heap[i]
	_heap[i] = _heap[j]
	_heap[j] = temp

## Compare two priorities based on the heap type
func _compare(a: float, b: float) -> bool:
	if heap_type == HeapType.MIN_HEAP:
		return a < b  # Min-heap: smaller priorities are more important
	else:
		return a > b  # Max-heap: larger priorities are more important
