module GeoHelper

	class Position
		attr_reader :x,:y
		
		def initialize(_x,_y)
			@x = _x.to_i
			@y = _y.to_i
		end

		def ==(other)
			x == other.x && y == other.y
		end

		# calculates distance in straight line
		def distance_to(position)
			Math.sqrt((position.x - x).abs ** 2 + (position.y - y).abs ** 2)
		end

		def to_s
			"(#{x},#{y})"
		end

		def to_a
			[x, y]
		end
	end

	def distance_to(other)
		other.position.distance_to self.position
	end

	def self.middle_point(position1, position2)
		x1, y1 = position1.x, position1.y
		x2, y2 = position2.x, position2.y
		Position.new((x1 + x2) / 2, (y1 + y2) / 2)
	end
end