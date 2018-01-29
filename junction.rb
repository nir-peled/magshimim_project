require 'set'
load 'map_static_object.rb'

class Junction < MapStaticObject
	attr_reader :outgoing_roads

	MAX_ROAD_NUM = 4

	def initialize(position, the_map, roads=[])
		super position
		throw ArgumentError, "Too many roads" if roads.size > MAX_ROAD_NUM

		@map = the_map
		@outgoing_roads = Set.new(roads)
		def @outgoing_roads.to_s
			map(&:to_s).join(',')
		end
	end

	def connect_to(other, speed_limit=nil)
		exit_road = Road.new [self, other], self.distance_to(other), speed_limit
		enter_road = Road.new [other, self], self.distance_to(other), speed_limit

		add_road exit_road
		other.add_road enter_road
	end

	def connected?(object)
		if object.is_a? Road
			@outgoing_roads.include? object
		elsif object.is_a? Junction
			@outgoing_roads.any? { |road| road.connected? object }
		else
			throw ArgumentError, "Object must be Road or Junction"
		end
	end

	def road_to(other)
		@outgoing_roads.find { |road| road.opposite_junction(self) == other }
	end

	def neighbors
		@outgoing_roads.map {|road| road.opposite_junction self }.compact
	end

	def cost_to(other)
		throw ArgumentError, "Junctions are not connected" if !connected?(other)
		road_to(other).passage_time
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
		throw ArgumentError, "Too many roads" if @outgoing_roads.size == MAX_ROAD_NUM
		@map.add_road road
		@outgoing_roads << road
	end

	def as_list_line
		"#{to_s.ljust(10,' ')}|#{position.to_s.center(10,' ')}|#{@outgoing_roads}"
	end

	def Junction.list_header
		"\nJunctions\n=========\n    name      |   POS    | Roads\n--------------------------"
	end
end
