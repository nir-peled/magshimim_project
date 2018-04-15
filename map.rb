load 'map_helper.rb'
load 'route_finder.rb'

class Map
	include MapHelper
	# include RouteFinder

	def initialize(map_image)
		@image = map_image
		init
	end

	def traffic(road)
	end

	def draw
		@image.draw(0, 0, 0)
		junctions.each &:draw
		roads.each &:draw
		cars.each &:draw
	end

	def route_for(from_junction, to_junction)
		unless junctions.include?(from_junction) && junctions.include?(to_junction)
			Log.warn "Junctions not on map"
			return []
		end
		route = RouteFinder.find_shortest_path(from_junction, to_junction)
	end
end
