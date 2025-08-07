class_name PriorityQueueTest extends Object

static func test():
	var pq_min = PriorityQueue.new()
	pq_min.heap_type = PriorityQueue.HeapType.MIN_HEAP
	
	print("=== Testing MIN_HEAP ===")
	
	# Add elements with different priorities
	pq_min.enqueue("A", 10)
	pq_min.enqueue("B", 5)
	pq_min.enqueue("C", 15)
	pq_min.enqueue("D", 1)
	pq_min.enqueue("E", 20)
	pq_min.enqueue("F", 3)
	pq_min.enqueue("G", 8)
	
	print("Peek (should be D): ", pq_min.peek())  
	
	print("Expected: D, F, B, G, A, C, E")
	while not pq_min.is_empty():
		print("Dequeued: ", pq_min.dequeue())
	
	print("\n=== Testing MIN_HEAP with Many Elements ===")
	
	# Add a larger number of elements
	var nums: Array[int] = []
	for i in range(26):
		nums.append(i)
	nums.shuffle()
	
	for num in nums:
		var letter = char(65 + num)  # Convert ASCII to letter
		pq_min.enqueue(letter, num)
	
	print("Peek (should be A): ", pq_min.peek())  
	
	print("Expected: A, B, C, ..., Y, Z")
	while not pq_min.is_empty():
		print("Dequeued: ", pq_min.dequeue())
	
	# ---------------------------
	
	var pq_max = PriorityQueue.new()
	pq_max.heap_type = PriorityQueue.HeapType.MAX_HEAP
	
	print("\n=== Testing MAX_HEAP ===")
	
	# Add elements with different priorities
	pq_max.enqueue("A", 10)
	pq_max.enqueue("B", 5)
	pq_max.enqueue("C", 15)
	pq_max.enqueue("D", 1)
	pq_max.enqueue("E", 20)
	pq_max.enqueue("F", 3)
	pq_max.enqueue("G", 8)
	
	print("Peek (should be E): ", pq_max.peek())  
	
	print("Expected: E, C, A, G, B, F, D")
	while not pq_max.is_empty():
		print("Dequeued: ", pq_max.dequeue())
	
	print("\n=== Testing MAX_HEAP with Many Elements ===")
	
	nums = []
	for i in range(26):
		nums.append(i)
	nums.shuffle()
	
	for num in nums:
		var letter = char(65 + num)  # Convert ASCII to letter
		pq_max.enqueue(letter, 26 - num)
	
	print("Peek (should be A): ", pq_max.peek())  
	
	print("Expected: A, B, C, ..., Y, Z")
	while not pq_max.is_empty():
		print("Dequeued: ", pq_max.dequeue())
