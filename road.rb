load 'map_static_object.rb'

class Road < MapStaticObject

	attr_reader :junctions, :speed_limit

	def initialize(junctions, road_speed_limit=nil)
		super nil
		@junctions = junctions
		@speed_limit = road_speed_limit
	end

	def ==(other)
		start_junction==other.start_junction && end_junction==other.end_junction
	end

	def connected?(junction)
		@junctions.include? junction
	end

	def opposite_junction(junction)
		junction == @junctions[0] ? junctions[1] : junctions[0]
	end

	def within_speed_limit?(speed)
		@speed_limit < 0 || speed <= @speed_limit
	end

	def start_junction
		@junctions[0]
	end

	def end_junction
		@junctions[1]
	end

	def as_list_line
		"#{to_s.ljust(10,' ')}| #{start_junction.to_s.ljust(5,' ')}| #{end_junction.to_s.ljust(5,' ')}"
	end
	
	def Road.list_header
		"\nRoads\n=========\nname      | From | To\n--------------------------"
	end
end
