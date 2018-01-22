require 'set'
require_relative 'log'

module MapHelper

	class MapError < StandardError; end

	# class RouteCalculator
	# 	def initialize j_start, j_end
	# 		@j_start = j_start
	# 		@j_end = j_end
	# 		@r_stack = []
	# 		@j_stack = []
	# 	end

	# 	def calculate
	# 		@j_stack << @j_start
	# 		branch_from @j_start
	# 		return @r_stack
	# 	end

	# 	def branch_from j
	# 		#puts "branch from #{j}"
	# 		j.outgoing_roads.each do |road|
	# 			#puts ".. branch to #{road}"
	# 			return true if dfs(road)
	# 		end
	# 		return false
	# 	end

	# 	def dfs road
	# 		if road.end_junction == @j_end
	# 			@r_stack << road
	# 			@j_stack << @j_end
	# 			#puts ".. Found it!!!"
	# 			return true
	# 		elsif @j_stack.include? road.end_junction
	# 			#puts ".. loop. Going back"
	# 			return false
	# 		else
	# 			#puts ".. pushing #{road} and #{road.end_junction}"
	# 			@r_stack << road
	# 			@j_stack << road.end_junction
	# 			#puts "Jumping on #{road} to #{road.end_junction}"
	# 			if branch_from road.end_junction
	# 				return true
	# 			else
	# 				@r_stack.pop
	# 				@j_stack.pop
	# 				return false
	# 			end
	# 		end
	# 	end
	# end

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
		car.set_mission self, from_junction, to_junction
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
		raise MapError.new "Road already on map" if roads.include? road

		add_junction road.start_junction
		add_junction road.end_junction

		roads << road
		road.map_name = "R#{roads_count}"
		Log.full "Road #{road} added. Roads: #{roads.count} Junctions: #{junctions.count}"
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