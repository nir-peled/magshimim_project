require 'gosu'
require 'json'
require_relative 'log'

load "misc.rb"
load "map_object.rb"
load "map.rb"
load "map_generator.rb"

class Simulator < Gosu::Window
	attr_reader :map
	def initialize(config_filename="config.json")
		config_file = File.read(config_filename)
		config_vars = JSON.parse(config_file, :symbolize_names => true)
		window_vars = config_vars[:window]
		super window_vars[:window_width], window_vars[:window_height]
		self.caption = window_vars[:window_caption]

		use_config_vars config_vars
		@cars_running = false
		# @map.print_map
	end

	def update
		# ...
	end

	def draw
		@map.draw
	end

	def start_running
		@map.start_cars
		@cars_running = true
		show
	end

	def button_down(id)
		case id
		when Gosu::KB_ESCAPE
			close
		when Gosu::MS_LEF
			@cars_running ? @map.pause_cars : @map.continue_cars
			@cars_running = !@cars_running
		else
			super
		end
	end

	def close
		@map.stop_cars
		Log.close_log
		super
	end

	private
	def use_config_vars(config_vars)
		set_images config_vars[:media]
		set_config_constants config_vars[:constants]
		fill_map config_vars[:map]
	end

	def set_images(media_vars)
		ObjectImage.set_media_dir media_vars[:media_dir]
		media_vars[:image_files].each { |image_type, image_filename|
			ObjectImage.init_image image_type, image_filename  if !image_filename.nil?
		}
		# ObjectImage.debug_images
	end

	def set_config_constants(const_vars)
		ObjectImage.set_draw_factor const_vars[:drawing_multiplier]
	end

	def fill_map(map_vars)
		@map = Map.new ObjectImage.get_image(:background)

		map_layout = get_map_layout(map_vars)
		MapGenerator.create_map(@map, map_layout)
		# ...
	end

	def get_map_layout(map_vars)
		if map_vars.respond_to? :to_s
			map_vars = map_vars.to_s
			layout_raw = map_vars.end_with?(".json") ? File.read(map_vars) : map_vars
			JSON.parse(layout_raw, :symbolize_names => true)
		elsif map_vars.respond_to? :to_h
			map_vars.to_h
		else
			raise ArgumentError, "#{map_vars} (#{map_vars.class}) cannot be used as a map layout"
		end
	end
end
