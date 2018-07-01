# this file includes misc methodes to
# make certain things easier

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
