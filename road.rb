load 'map_static_object.rb'

class Road < MapStaticObject
	attr_reader :junctions, :speed_limit, :length

	module SpeedLimit
		MaxSpeedLimit = 3
		Normal = 2
		Slow = 1
	end

	def initialize(junctions, length, road_speed_limit=nil)
		super nil
		@length = length
		@junctions = junctions
		@speed_limit = road_speed_limit
	end

	def ==(other)
		other.is_a?(Road) && start_junction == other.start_junction && end_junction == other.end_junction
	end

	def eql?(other)
		start_junction == other.start_junction && end_junction == other.end_junction
	end

	def hash
		"#{start_junction.hash}0000#{end_junction.hash}".to_i
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

	def passage_time(speed=@speed_limit)
		(@length / speed.to_f).ceil
	end

	def as_list_line
		name_part = to_s.ljust(10,' ')
		start_part = start_junction.to_s.ljust(5,' ')
		end_part = end_junction.to_s.ljust(5,' ')
		length_part = @length.to_s.ljust(5,' ')
		speed_part = @speed_limit.to_s.ljust(5,' ')
		"#{name_part}| #{start_part}| #{end_part}| #{length_part}| #{speed_part}"
	end
	
	def Road.list_header
		"\nRoads\n=========\nname      | From | To | Length | Speed Limit\n--------------------------"
	end
end
