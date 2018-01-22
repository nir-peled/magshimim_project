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
			(position.x - x).abs + (position.y - y).abs
		end

		def to_s
			"#{x},#{y}"
		end
	end


end