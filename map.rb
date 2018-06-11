load 'map_helper.rb'
load 'route_finder.rb'

class Map
	include MapHelper

	def initialize(map_image)
		@image = map_image
		init
	end

	def traffic(road, distance)
		road_traffic = cars_on_object(road).sort_by(&:last)
		road_traffic.bsearch { |car, dis| dis > distance }
	end

	def junction_occupation_time(junction)
		car, distance = cars_on_object(junction).first
		distance.to_f
	end

	def cars_to_junction(junction)
		roads_to_junction = junction.ingoing_roads.sort_by {|r| r.angle }
		roads_to_junction.map { |r| cars_on_object(r).max_by(&:last) }
	end

	def start_cars
		cars.each &:go!
	end

	def pause_cars
		cars.each &:pause_driving
	end

	def continue_cars
		cars.each &:continue_driving
	end

	def stop_cars
		cars.each &:force_finish
	end

	def draw
		@image.draw(0, 0, 0)
		junctions.each &:draw
		roads.each &:draw
		cars.each &:draw
	end

	def route_for(from_junction, to_junction)
		Log.info "calculating route from #{from_junction} to #{to_junction}"
		unless junctions.include?(from_junction) && junctions.include?(to_junction)
			Log.warn "Junctions not on map"
			return []
		end
		route = RouteFinder.find_shortest_path(from_junction, to_junction)
	end
end
