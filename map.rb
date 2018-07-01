load 'map_helper.rb'
load 'route_finder.rb'

# this is the singular Map object's class. 
# It represents the Map, and the objects on it. 
class Map
	include MapHelper

	def initialize(map_image)
		@image = map_image
		init
	end

	# returns the car on <road> closest to <distance>
	# in front of it (with smaller distance left)
	def traffic(road, distance_left)
		road_traffic = cars_on_object(road).sort_by!(&:last).reverse!
		road_traffic.bsearch { |car, dis| dis < distance_left }
	end

	# returns the number of ticks left until <junction>
	# is unoccupied
	def junction_occupation_time(junction)
		car, distance = cars_on_object(junction).first
		distance.to_f
	end

	# returns the cars going to <junction> and their
	# distance from it
	def cars_to_junction(junction)
		roads_to_junction = junction.ingoing_roads.sort_by {|r| r.angle }
		roads_to_junction.map {|r| cars_on_object(r).min_by(&:last) }.compact
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

	# draws the map
	def draw
		@image.draw(0, 0, 0)
		junctions.each &:draw
		roads.each &:draw
		cars.each &:draw
	end

	# returns the shortest route from <from_junction>
	# to <to_junction>
	def route_for(from_junction, to_junction)
		Log.info "calculating route from #{from_junction} to #{to_junction}"
		unless junctions.include?(from_junction) && junctions.include?(to_junction)
			Log.warn "Junctions not on map"
			return []
		end
		route = RouteFinder.find_shortest_path(from_junction, to_junction)
	end
end
