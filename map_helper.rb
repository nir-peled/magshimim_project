require 'set'
load "junction.rb"
load "road.rb"
load "car.rb"

module MapHelper

	class MapError < StandardError; end

	def init
		@cars = Set.new
		@roads = Set.new
		@junctions = Set.new
	end

	def cars_count; cars.length; end
	def roads_count; roads.length; end
	def junctions_count; junctions.length end

	def add_mission (car, from_junction, to_junction)
		car.set_mission self, from_junction, to_junction
	end

	def create_car(position, length=0)
		car = Car.new position, length, image:ObjectImage.get_image(:car)
		add_car car
	end

	def add_car(car)
		if cars.add?(car)
			car.map_name = "C#{cars_count}"
		else
			Log.warn "Car #{car} already on map"
		end
		car
	end

	def get_car(name:nil, id:nil)
		return nil unless name || id

		if id
			res = cars.select { |car| car.id == id }
			return res[0] if res.count == 1
			return res if res.count > 1
			return nil 
		end

		cars.select {|car| car.name == name}
	end

	def add_road(road)
		raise MapError.new "Road #{road.junctions.to_s} already on map" if roads.include? road

		# self_add_junction road.start_junction
		# self_add_junction road.end_junction

		roads << road
		road.map_name = "R#{roads_count}"
	rescue MapError => e
		Log.warn e.message
	end

	def roads_include?(r)
		roads.include? r
	end

	def print_map
		Log.blank "Junctions: #{junctions.count}"
		Log.blank "    " << Junction.list_header
		junctions.each_with_index { |junction,i| Log.blank "(#{i}) #{junction.as_list_line}" }

		Log.full "Roads: #{roads.count}"
		Log.blank Road.list_header
		roads.each { |road| Log.blank road.as_list_line }

		Log.blank Car.list_header
		cars.each { |car| Log.blank car.as_list_line }
		""
	end

	def add_junction(position)
		throw ArgumentError, "Position has a Junction already" if junctions.any? { |j| j.position == position }
		junction = Junction.new position, self, [], image:ObjectImage.get_image(:junction)
		self_add_junction junction
		junction
	end

	def connect_junctions(start_junction, end_junction, opt={})
		create_road start_junction, end_junction, opt[:speed_limit]
		create_road end_junction, start_junction, opt[:speed_limit] if opt[:two_way]
	end

	def create_road(start_junction, end_junction, speed_limit=nil)
		road = Road.new [start_junction, end_junction], start_junction.distance_to(end_junction),
		 road_speed_limit:speed_limit
		add_road road
		start_junction.add_road road
	end

	def update_distance_on_road(car, road, distance)
		car.move road.start_junction.position
		car.push road.direction, distance
		car.set_angle road.angle
	end

	def start_cars
		cars.each &:go!
	end

	def stop_cars
		cars.each &:force_finish
	end

private
	attr :cars
	attr :roads
	attr :junctions

	def self_add_junction(junction)
		junctions << junction
		junction.map_name = "J#{junctions_count}"
	end
end