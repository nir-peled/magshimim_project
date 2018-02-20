require 'set'
require_relative 'log'

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

	def add_car(car)
		if cars.add?(car)
			car.map_name = "C#{cars_count}"
		else
			Log.warn "Car #{car} already on map"
		end
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
		junction = Junction.new position, self
		self_add_junction junction
		junction
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