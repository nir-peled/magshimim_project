load 'map_static_object.rb'

class Road < MapStaticObject

	attr_reader :junctions, :speed_limit
	
	def initialize(junctions, road_speed_limit=-1)
		super nil
		@junctions = junctions
		@speed_limit = road_speed_limit
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

end
