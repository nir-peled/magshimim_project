load 'geo_helper.rb'

class MapObject

	include GeoHelper
	
	attr_reader :position
	attr_accessor :map_name

	def initialize(position, picture=nil,  op={})
		@position = position
		@picture = Gosu::Image.new(picture) if !picture.nil?
	end

	def picture
		@picture.dup
	end

	def draw
		@picture.draw_rot(x, y, 1, @angle)
	end

	def to_s() map_name; end

private

	def map_bound_pos(pos, bound)
		if @map_bound
			if pos > 0
				[pos, bound - Simulator::BORDER_SIZE].min
			else
				Simulator::BORDER_SIZE
			end
		else
			pos % bound
		end
	end

end
