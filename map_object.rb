load 'geo_helper.rb'
load 'object_image.rb'

# this class represents a map objec
# all other map object classes inherit from this one
class MapObject
	@@id_counter = -1
	include GeoHelper
	
	attr_reader :position, :id, :angle
	attr_accessor :map_name

	def initialize(position, opt={})
		@id = @@id_counter += 1
		@position = position
		@image = opt[:image]
		@map_name = opt[:map_name]
		@angle = opt[:angle] ? opt[:angle] : 0
	end

	def draw(layer=1)
		return if position.nil?
		# ObjectImage.draw_image type, position.x, position.y, layer, @angle
		@image.draw_on_map(position.x, position.y, layer, @angle)
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
