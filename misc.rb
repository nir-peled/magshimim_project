
class Array
	def bsearch_index(&block)
		each_with_index.to_a.bsearch {|item, _| block.call item }.last
	end
end

class Module
	def constants_values
		constants.map {|const| self.const_get const }
	end
end

module Enumerable
	def map_if
		mapped_vals = []
		each { |e|
			val = yield e
			mapped_vals << val  if !val.nil?
		}
		mapped_vals
	end
end
