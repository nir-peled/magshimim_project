require 'set'
require 'thread'
load 'kinetic.rb'
load "junction.rb"
load "road.rb"
load "car.rb"

# this is a module for Map that handle
# the map objects directly.
module MapHelper

	class MapError < StandardError; end

	def init
		@cars = Set.new
		@roads = Set.new
		@junctions = Set.new

		# tracks the car's positions on the map
		@car_positions = {}
		@position_mutex = Mutex.new
	end

	def cars_count; cars.length; end
	def roads_count; roads.length; end
	def junctions_count; junctions.length end

	# adds a new mission to a car. and_back - from-to-from. 
	# recursive - from-to-from-to-...
	def add_mission (car, from_junction, to_junction, and_back=true, recursive=true)
		and_back = and_back.nil? ? true : and_back
		recursive = recursive.nil? ? true : recursive
		car.set_mission self, from_junction, to_junction, and_back, recursive
	end

	# creates a new car at <position>
	def create_car(position, length=0)
		car = Car.new position, length, image:ObjectImage.get_image(:car)
		add_car car
	end

	# adds an existing car to the map
	def add_car(car)
		if cars.add?(car)
			car.map_name = "C#{cars_count}"
		else
			Log.warn "Car #{car} already on map"
		end
		car
	end

	# returns a car from the map by name/id
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

	# adds an existing road to the map
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

	# prints the map to the log as tables
	def print_map
		Log.full "Junctions: #{junctions.count}"
		Log.full "    " << Junction.list_header
		junctions.each_with_index { |junction,i| Log.full "(#{i}) #{junction.as_list_line}" }

		Log.full "Roads: #{roads.count}"
		Log.full Road.list_header
		roads.each { |road| Log.full road.as_list_line }

		Log.full Car.list_header
		cars.each { |car| Log.full car.as_list_line }
		""
	end

	# creates a new junction at <position>
	def add_junction(position)
		throw ArgumentError, "Position has a Junction already" if junctions.any? { |j| j.position == position }
		junction = Junction.new position, self, [], image:ObjectImage.get_image(:junction)
		self_add_junction junction
		junction
	end

	# connect between two junctions on the map. 
	# opt - :and_back to create the road both ways
	# :speed_limit to specify the road's speed limit
	def connect_junctions(start_junction, end_junction, opt={})
		create_road start_junction, end_junction, opt[:speed_limit]
		create_road end_junction, start_junction, opt[:speed_limit] if opt[:two_way]
	end

	# creates a new one-way road from <start_junction> to <from_junction>
	def create_road(start_junction, end_junction, speed_limit=nil)
		road = Road.new [start_junction, end_junction], start_junction.distance_to(end_junction),
		 road_speed_limit:speed_limit
		add_road road
		start_junction.add_road road
		end_junction.add_ingoing_road road
	end

	# updates a car's position on the map and in 
	# map's trackings
	def update_car_position(car, map_object, distance)
		@position_mutex.lock
		@car_positions[car] = [map_object, distance]
		@position_mutex.unlock
		if map_object.nil?
			car.move nil
			return
		end

		Log.full "#{car}> [#{map_object}, #{distance}]"  if map_object.is_a? Junction
		update_distance_on_road car, map_object, distance  if map_object.is_a? Road

		check_for_collision car
	ensure
		@position_mutex.unlock  if @position_mutex.owned?
	end

	# for draw purposes
	# update a car's physical position on a road
	def update_distance_on_road(car, road, distance)
		distance_from_start_j = road.length - distance
		car.move road.start_junction.position
		car.push road.direction, distance_from_start_j
		car.set_angle road.angle
	end

	# returns the cars currently on <object> (Road/Junction)
	def cars_on_object(obj)
		@position_mutex.lock
		# find car, [map_obj, distance] where map_obj==<obj>
		# cars_on_obj = @car_positions.find_all { |car, pos| pos.first == obj }
		# [car, distance]
		# cars_on_obj.map {|car, pos| [car, pos.last] }

		# [car, distance] where map_obj==<obj>
		@car_positions.map_if {|car, pos| [car, pos.last] if pos.first == obj }
	ensure
		@position_mutex.unlock  if @position_mutex.owned?
	end

private
	attr :cars
	attr :roads
	attr :junctions

	def self_add_junction(junction)
		junctions << junction
		junction.map_name = "J#{junctions_count}"
	end

	def check_for_collision(car)
		map_object, distance = @car_positions[car]
		return if map_object.nil?
		other_cars = cars_on_object(map_object).delete_if {|c, dis| c == car }
		any_crashed = false

		other_cars.each { |c, o_distance| 
			if map_object.is_a?(Junction) || (o_distance - distance).abs < c.length
				c.crashed "collision on #{map_object}"
				any_crashed = true
			end
		}

		car.crashed "collision on #{map_object}" if any_crashed
	end
end
