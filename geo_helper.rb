module GeoHelper

	class Position
		attr_reader :x,:y

		def initialize(_x,_y)
			@x = _x.to_i
			@y = _y.to_i
		end

		def ==(other)
			x==other.x && y==other.y
		end

		# calculates distance in straight line
		def distance_to(position)
			Math.sqrt((position.x - x).abs ** 2 + (position.y - y).abs ** 2)
		end

		def to_s
			"(#{x},#{y})"
		end
	end

	def distance_to(other)
		other.position.distance_to self.position
	end
end