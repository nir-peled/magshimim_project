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

	def add_car(car)
		cars << car
		car.map_name = "C#{cars_count}"
		Log.full "Car #{car.map_name} added."
	end

	def add_road(road)
		roads.each do |r|
			if r.start_junction == road.start_junction && r.end_junction==road.end_junction
				raise ArgumentError.new "Road already on map"
			end
		end

		add_junction road.start_junction
		add_junction road.end_junction

		roads << road
		road.map_name = "R#{roads_count}"
		Log.full "Road #{road.map_name} added."
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