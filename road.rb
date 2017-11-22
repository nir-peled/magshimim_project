
class Road < MapObject
	attr_reader :junctions, :speed_limit
	def initialize(pos_x, pos_y, end_junctions, road_speed_limit=-1)
		super pos_x, pos_y, :movable => false
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
end
