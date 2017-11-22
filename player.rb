require_relative "map_object.rb"

class Player < MapObject
	SLOW_RATE = 0.95
	def initialize(pos_x, pos_y, avatar="./media/starfighter.bmp")
		super avatar, pos_x, pos_y, :map_bound => true
		@vel_x = @vel_y = @angle = 0.0
	end

	def turn_left
		@angle -= 4.5
	end

	def turn_right
		@angle += 4.5
	end

	def accelerate
		@vel_x += Gosu.offset_x(@angle, 0.5)
		@vel_y += Gosu.offset_y(@angle, 0.5)
	end

	def move
		super x + @vel_x, y + @vel_y
		@vel_x *= SLOW_RATE
		@vel_y *= SLOW_RATE
	end
end