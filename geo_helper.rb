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

		def distance_to(position)
			if position.x == x
				(position.y - y).abs
			elsif position.y == y
				(position.x - x).abs
			else
				raise ArgumentError, "Unmeasurable distance"
			end
		end

		def to_s
			"#{x},#{y}"
		end
	end


end