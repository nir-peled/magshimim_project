
class PriorityQueue
	class Element
		include Comparable
		attr_accessor :val, :priority
		def initialize(val, pri)
			@value = val
			@priority = pri
		end

		def <=>(other)
			@priority <=> other.priority
		end
	end

	attr_reader :is_bigger_proc

	def initialize(elements=nil, cmp=lambda {|a, b| a >= b})
		@elements = [nil]
		@is_bigger_proc = cmp
	end

	def <<(element, priority)
		@elements << Element.new element, priority
		bubble_up(@elements.size - 1)
	end
	alias_method :push, :<<
	alias_method :enqueue, :<<

	def pop
		exchange(1, @elements.size - 1)
		max = @elements.pop
		bubble_down(1)
		max
	end
	alias_method :dequeue, :pop

	def peek
		@elements[1].value
	end
	alias_method :first, :peek

	def size
		@elements.size - 1 #the first is nil
	end
	alias_method :length, :size

	def change_priority(value, new_priority)
		element_index = @elements.index {|e| e.value == value}
		element = @elements[element_index]

		old_priority = element.priority
		element.priority = new_priority
		if @is_bigger_proc.call(old_priority, new_priority)
			bubble_up element_index
		else
			bubble_down element_index
		end
		self
	end

	private

	def bubble_up(index)
		parent_index = (index / 2)

		return if index <= 1
		return if @is_bigger_proc.call(@elements[parent_index], @elements[index])

		exchange(index, parent_index)
		bubble_up(parent_index)
	end

	def bubble_down(index)
		child_index = (index * 2)

		return if child_index > @elements.size - 1

		not_the_last_element = child_index < @elements.size - 1
		left_element = @elements[child_index]
		right_element = @elements[child_index + 1]
		child_index += 1 if not_the_last_element && !@is_bigger_proc.call(left_element, right_element)

		return if @is_bigger_proc.call(@elements[index], @elements[child_index])

		exchange(index, child_index)
		bubble_down(child_index)
	end

	def exchange(source, target)
		@elements[source], @elements[target] = @elements[target], @elements[source]
	end
end
