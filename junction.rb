require 'set'
load 'map_static_object.rb'

class Junction < MapStaticObject
	attr_reader :outgoing_roads

	def initialize(position)
		super
		@outgoing_roads = Set.new
		def @outgoing_roads.to_s
			self.map {|r| "#{r.to_s}"}.join(',')
		end
	end

	# for Set operations
	def ==(other)
		self.position==other.position
	end

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
		"#{to_s.ljust(10,' ')}|#{position.to_s.center(10,' ')}|#{@outgoing_roads}"
	end

	def Junction.list_header
		"\nJunctions\n=========\n    name      |   POS    | Roads\n--------------------------"
	end
end
