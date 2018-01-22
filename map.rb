load 'map_helper.rb'

class Map
	include MapHelper
	# include RouteFinder

	def initialize(args=nil)
		init
	end

	def traffic(road)
	end

	def route_for(from_junction, to_junction)
		unless junctions.include?(from_junction) && junctions.include?(to_junction)
			Log.warn "Junctions not on map"
			return []
		end
		route = RouteFinder.find_shortest_path(from_junction, to_junction).calculate
	ensure
		Log.info "Route is..."
		Log.info route
	end
end
