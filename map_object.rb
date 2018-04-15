load 'geo_helper.rb'
load 'object_image.rb'

class MapObject
	@@id_counter = -1
	include GeoHelper
	
	attr_reader :position, :id, :angle
	attr_accessor :map_name

	def initialize(position, opt={})
		@id = @@id_counter += 1
		@position = position
		@image_type = opt[:image]
		@map_name = opt[:map_name]
		@angle = opt[:angle] ? opt[:angle] : 0
	end

	def draw(layer=1)
		# ObjectImage.draw_image type, position.x, position.y, layer, @angle
		@image_type.draw_on_map(position.x, position.y, layer, @angle)
	end

	def type
		!@image_type.nil? ? @image_type : self.class.to_s.downcase.to_sym
	end

	def to_s
		if !map_name.nil?
			map_name
		else
			"#{self.class}::#{position}"
		end
	end
	alias_method :inspect, :to_s
end
