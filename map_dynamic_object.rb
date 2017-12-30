load 'map_object.rb'

class MapDynamicObject < MapObject

	def initialize
		super
	end

	def move(new_x, new_y)
		return if !@movable
		pos_x = map_bound_pos new_x, Simulator::WIDTH
		pos_y = map_bound_pos new_y, Simulator::HEIGHT
		@pos = [pos_x, pos_y]
	end

	def new_position(new_pos)
		move *new_pos
	end

	def push(offset)
		move [x + offset[0], y + offset[1]]
	end

end