
class MapObject
	def initialize(picture, pos_x=0.0, pos_y=0.0, op={})
		@pos = [pos_x.to_f, pos_y.to_f]
		@picture = Gosu::Image.new(picture) if !picture.nil?

		@map_bound = op[:map_bound] || false
		@movable = op.has_key? :movable ? op[:movable] : true
	end

	def position
		@pos.dup
	end

	def picture
		@picture.dup
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

	def x
		@pos[0]	
	end

	def y
		@pos[1]
	end

	def draw
		@picture.draw_rot(x, y, 1, @angle)
	end

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
