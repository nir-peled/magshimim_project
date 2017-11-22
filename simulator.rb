require 'gosu'

require_relative "map_object.rb"
require_relative "player.rb"

class Simulator < Gosu::Window
	WIDTH, HEIGHT = 640, 480
	BORDER_SIZE = 0
	def initialize
		super WIDTH, HEIGHT
		self.caption = "Tutorial Game"
		@map = Gosu::Image.new("./media/space.png", :tileable => true)
		@player = Player.new(WIDTH / 2.0, HEIGHT / 2.0)
	end

	def update
		if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
			@player.turn_left
		elsif Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
			@player.turn_right
		end

		if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
			@player.accelerate
		end

		@player.move
	end

	def draw
		@map.draw(0, 0, 0)
		@player.draw
	end

	def button_down(id)
		if id == Gosu::KB_ESCAPE
			close
		else
			super
		end
	end
	
	# self.constants.each {|const| define_method(const.downcase) { const_get const } }
end

Simulator.new.show