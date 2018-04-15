load 'map_object.rb'

class MapDynamicObject < MapObject
	def initialize(start_pos, opt={})
		super start_pos, opt
	end

	def move(new_pos, new_angle=nil)
		@position = new_pos
		set_angle new_angle if !new_angle.nil?
	end

	def set_angle(new_angle)
		if is_angle_legal new_angle
			@angle = new_angle
		else
			raise ArgumentError, "angle #{new_angle.inspect} is not legal"
		end
	end

	def rotate(angle_offset)
		set_angle @angle + angle_offset
	end

	def is_angle_legal(angle_check)
		(-360.0..360.0).include? angle_check
	end

	def push(offset, amount=1)
		new_x = position.x + offset[0] * amount
		new_y = position.y + offset[1] * amount
		move GeoHelper::Position.new(new_x, new_y)
	end

end