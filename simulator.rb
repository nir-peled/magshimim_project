require 'gosu'
require 'json'
require_relative 'log'

load "map_object.rb"
load "map.rb"
load "map_generator.rb"

class Simulator < Gosu::Window
	def initialize(config_filename="config.json")
		config_file = File.read(config_filename)
		config_vars = JSON.parse(config_file, :symbolize_names => true)
		window_vars = config_vars[:window]
		super window_vars[:window_width], window_vars[:window_height]
		self.caption = window_vars[:window_caption]

		use_config_vars config_vars
		@map.print_map
	end

	def update
		# ...
	end

	def draw
		@map.draw
	end

	def start_running
		@map.start_cars
		show
	end

	def button_down(id)
		if id == Gosu::KB_ESCAPE
			stop_running
		else
			super
		end
	end

	private
	def stop_running
		close
		@map.stop_cars
	end

	def use_config_vars(config_vars)
		set_images config_vars[:media]
		set_config_constants config_vars[:constants]
		fill_map config_vars[:map]
	end

	def set_images(media_vars)
		media_dir = media_vars[:media_dir]
		media_vars[:image_files].each { |image_type, image_filename|
			ObjectImage.init_image image_type,
			 File.join(media_dir, image_filename) if !image_filename.nil?
		}
	end

	def set_config_constants(const_vars)
		ObjectImage.set_draw_factor const_vars[:drawing_multiplier]
	end

	def fill_map(map_vars)
		@map = Map.new ObjectImage.get_image(:background)
		MapGenerator.create_map(@map, map_vars[:junctions], map_vars[:roads], map_vars[:cars])
		# ...
	end
end
