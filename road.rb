load 'map_static_object.rb'

# this class represents a Road.
# include length, end junctions and speed limit
# includes the Road's direction or angle
class Road < MapStaticObject
	attr_reader :junctions, :speed_limit, :length

	ROAD_COLOR = Gosu::Color::AQUA

	module SpeedLimit
		MaxSpeedLimit = Kinetic::Metric.new(3)
		Normal = Kinetic::Metric.new(2)
		Slow = Kinetic::Metric.new(1)
	end

	def initialize(junctions, length, opt={})
		@length = length
		@junctions = junctions
		@speed_limit = opt[:road_speed_limit]
		my_center = GeoHelper.middle_point(*junctions.map(&:position))
		angle = Gosu.angle(*start_junction.position, *end_junction.position)
		super my_center, angle:angle
	end

	def ==(other)
		other.is_a?(Road) && start_junction == other.start_junction && end_junction == other.end_junction
	end

	def eql?(other)
		self == other
	end

	def hash
		"#{start_junction.hash}0000#{end_junction.hash}".to_i
	end

	def draw
		ObjectImage.draw_line(start_junction.position, end_junction.position, ROAD_COLOR)
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

	# returns a point on the unit circle to match the direction
	# of the road
	def direction
		point_x = end_junction.position.x - start_junction.position.x
		point_y = end_junction.position.y - start_junction.position.y
		[point_x / @length, point_y / @length]
	end

	def angle
		args = @junctions.flat_map {|j| j.position.to_a }
		Gosu.angle(*args)
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
