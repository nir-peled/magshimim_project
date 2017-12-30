require 'set'
load 'map_static_object.rb'

class Junction < MapStaticObject

	def initialize(position)
		super position
		@outgoing_roads = Set.new
	end

	# for Set operations
	def eql?(other)
		self.position==other.position
	end

	# for Set operations
	def hash
		"#{position.x}0000#{position.y}".to_i
	end

	def add_road(road)
		@outgoing_roads << road
	end

	def as_list_line
		"#{to_s.ljust(10,' ')}|#{position.to_s.center(10,' ')}"
	end

	def Junction.list_header
		"\nJunctions\n=========\nname      |   POS    \n--------------------------"
	end
end
