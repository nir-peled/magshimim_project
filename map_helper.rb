require 'set'
require_relative 'log'

module MapHelper

	def init
		@cars = Set.new
		@roads = Set.new
		@junctions = Set.new
	end

	def cars_count; cars.length; end
	def roads_count; roads.length; end
	def junctions_count; junctions.length end

	def add_mission (car, from_junction, to_junction)
		add_car car
		car.set_mission from_junction, to_junction
	end

	def add_car(car)
		if cars.add?(car)
			car.map_name = "C#{cars_count}"
			Log.full "Car #{car} added."
		else
			Log.full "Car #{car} already on map"
		end
	end

	def get_car(name:nil, id:nil)
		return nil unless name||id

		if id
			res = cars.select { |car| car.id==id }
			return res[0] if res.count==1
			return res if res.count>1
			return nil 
		end

		cars.select {|car| car.name==name}
	end

	def add_road(road)
		raise ArgumentError.new "Road already on map" if roads.include? road

		add_junction road.start_junction
		add_junction road.end_junction

		roads << road
		road.map_name = "R#{roads_count}"
		Log.full "Road #{road} added."
	end

	def print_map
		Log.blank Junction.list_header
		junctions.each { |junction| Log.blank junction.as_list_line }

		Log.blank Road.list_header
		roads.each { |road| Log.blank road.as_list_line }

		Log.blank Car.list_header
		cars.each { |car| Log.blank car.as_list_line }
	end

private
	attr :cars
	attr :roads
	attr :junctions

	def add_junction(junction)
		junctions << junction
		junction.map_name = "J#{junctions_count}"
		Log.full "Junction #{junction.map_name} added."
	end
end