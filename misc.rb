
class Array
	def bsearch_index(&block)
		each_with_index.to_a.bsearch {|item, _| block.call item }.last
	end
end
