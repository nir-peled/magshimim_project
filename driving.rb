
# this module handles the driving procces. 
# it recieves instructions from Mission, 
# and controls the speed and acceleration
# on Roads, and turning in Junctions
module Driving
	def init_driving(junction)
		# the instructions given by Mission to drive
		# according to
		@driving_instructions = []
		@driving_position = junction

		# starts at random to differentiate time of start
		# between cars
		@distance = rand(Kinetic::JunctionTurnTime.to_i)
		@speed =  Kinetic::SpeedOnJunction
		@speed_before_junction = Kinetic::Metric.zero

		@engine = :Parked # the state of the engine: Parked, Driving or Crashed
		@driving_state = :NoState # the state for calc_accel_to_junction:
		# NoState, Normal or Slowing

		@crashed = false
		@driver = Thread.new { driver_control } if @driver.nil?
		
		return @driver
	end

	def stop_driving
		remove_car_from_map
		@driver.kill
	end

	def pause_driving
		@driver.stop
	end

	def continue_driving
		@driver.run
	end
	
	# instruct the car to drive next on <road>
	def drive_on(road)
		@driving_instructions << road
		start_driving if @engine == :Parked
	end

	# instruct the car to park at the next junction
	def park_at_next_junction
		@driving_instructions << :ParkNext
	end

	# tells the car it crashed. used by Map
	def crashed(message)
		@crashed = true
		@crash_message = message
	end

	protected
	attr :speed
	attr :distance
	attr :accel

	# calculates the time to arrive at next junction
	# adds the time to accelerate (or deccelerate) to
	# junction entry speed, and the time to cross
	# <gap> at junction entry speed
	def time_to_junction(gap)
		Kinetic.time_to_junction_speed(@speed) + gap / Kinetic::MaxJunctionEnterSpeed
	end

	private
	def start_driving
		Log.full "Starting to drive"
		@driving_state = :Normal
		@engine = :Running
	end

	# the main Driving control loop
	# each tick, calculates new position, accel
	# and speed, and reports them to the map
	def driver_control
		while !@crashed
			calc_driving_position_and_status
			report_driving_position_and_status
			sleep Kinetic::DriverControlLoopDelay
		end
		crash_car @crash_message
	rescue StandardError => e
		Log.error "#{map_name} > #{e.class}: #{e.message}"
		# crash_car e.message
		raise e # for debug
	rescue Exception => e
		Log.error "#{map_name} > #{e.class}: #{e.message}"
		raise e
	end

	# caculates position for this tick, and
	# accel and speed for the next on road.
	# on junction it just counts <Kinetic::JunctionTurnTime>
	# ticks
	def calc_driving_position_and_status
		return if @engine != :Running
		@distance += @speed
		Log.full ">> ===== #{map_name}: Pos:#{@driving_position}. Speed:#{@speed}. Distance: #{@distance} (#{distance_left_on_road})"

		if on_road
			calculate_new_speed_on_road
		else # on junction
			prepare_to_leave_junction if @distance == Kinetic::JunctionTurnTime
		end
	end

	def calculate_new_speed_on_road
		if distance_left_on_road <= Kinetic::JunctionRadius
			# enter junction
			if @speed > Kinetic::MaxJunctionEnterSpeed
				crash_car "enters junction too fast"
			else
				end_road
			end
		else
			@speed += calc_new_accel
		end
	end

	# calculates new accel in two dimensions and picking
	# the lowest:
	# first, accel required to enter the next junction in
	# required speed (or to stop before the junction),
	# and second, accel required to not crash into the car
	# in front of this one (if exists)
	def calc_new_accel
		traffic = find_road_traffic
		
		junction_accel = calc_junction_accel
		car_accel = calc_car_accel(traffic)

		@accel = [junction_accel, car_accel].compact.min
	ensure
		Log.full "#{map_name}> new accel: #{@accel}."
	end

	def find_road_traffic
		@map.traffic(on_road, distance_left_on_road)
	end

	def calc_junction_accel
		junction_gap = deccel_distance_gap
		# the distance left on the road after deccelrating
		# to juncion entry speed

		if is_occupied_at_arrival(junction_gap)
			return calc_accel_to_junction stop_before_junction_gap, Kinetic::Metric.zero
		else
			return calc_accel_to_junction junction_gap 
		end
	end

	# checkes if junction will be occupied at arrival. 
	# checkes if a car in the junction will stay there at arrival, 
	# or if another car with higher priority will ernter it. 
	def is_occupied_at_arrival(gap)
		occupation_time = @map.junction_occupation_time(on_road.end_junction)
		cars_on_other_roads = @map.cars_to_junction(on_road.end_junction)
		my_i = cars_on_other_roads.index {|car, _dis| car == self }
		return false if my_i.nil? # there is a car before this one

		car_has_passage = cars_on_other_roads.each_with_index.any? {|arr, i|
			car, dis = arr
			i < my_i && dis <= Kinetic::JunctionApproachDistance
		}

		return occupation_time >= time_to_junction(gap) || car_has_passage
	end

	# returns the accel needed to reach junction at <min_speed>,
	# based on <gap> calculated predicted with slow decceleration
	def calc_accel_to_junction(gap, min_speed=Kinetic::MaxJunctionEnterSpeed)
		Log.debug "#{map_name}> gap=#{gap}"
		@driving_state = :Normal  if @speed < min_speed # no need to slow down

		if gap < 0 # overshooting, slow down fast
			@driving_state = :Slowing
			return deccelerate_to min_speed
		elsif @driving_state == :Normal # the car did not begin slowing
			if gap > Kinetic::JunctionApproachDistance
				# has enough room to accelerate
				return accelerate_to [on_road.speed_limit, distance_left_on_road].min
			elsif gap > Kinetic::JunctionRadius && @speed < min_speed
				# little distance left before junction, speed up
				return accelerate_to min_speed
			end
		end
		@driving_state = :Slowing
		Log.debug "#{map_name}> slowing normal"
		deccelerate_to min_speed, Kinetic::Accel::SlowNormal
	end

	# calculates accel required in order not to
	# crash into the next car, if one exists
	def calc_car_accel(traffic)
		return nil  if traffic.nil? || (traffic.is_a?(Array) && traffic.empty?)

		other, other_distance = traffic
		car_gap = car_distance_gap(other, other_distance)
		calc_accel_to_car(car_gap, other.speed)
	end

	# calculates the distance left on road
	# if the car will start to slow down, 
	# until reaching junction entry speed
	def deccel_distance_gap
		distance_left_on_road - Kinetic.deccel_distance_for_approach(@speed)
	end

	# calculates the distance left on road
	# if the car will start to slow down, 
	# until stopping
	def stop_before_junction_gap
		distance_left_on_road - Kinetic::JunctionRadius - Kinetic.distance_to_stop(@speed)
	end

	# calculates the distance left between the cars
	# if both will start an emergency break
	def car_distance_gap(other, other_distance)
		other_distance_to_stop = other_distance - Kinetic.emergency_stop_distance(other.speed)
		my_distance_to_stop = distance_left_on_road - Kinetic.emergency_stop_distance(speed)

		my_distance_to_stop - other_distance_to_stop - other.length
	end

	def calc_accel_to_car(gap, other_speed)
		if gap > Kinetic::SufficientCarGap
			Kinetic::Accel::FastAccel
		elsif gap > Kinetic::MinimalCarGap
			Kinetic::Accel::SlowAccel
		else
			deccelerate_to other_speed, Kinetic::Accel::EmergencyBreak
		end
	end

	# chooses accel required to reach <target_speed>, from
	# available accel rates
	def accelerate_to(target_speed, max_accel=Kinetic::Accel::FastAccel)
		delta = target_speed - @speed
		if delta >= Kinetic::Accel::FastAccel
			Kinetic::Accel::FastAccel
		elsif delta >= Kinetic::Accel::NormalAccel
			Kinetic::Accel::NormalAccel
		elsif delta >= Kinetic::Accel::SlowAccel
			Kinetic::Accel::SlowAccel
		else
			Kinetic::Accel::NoAccel
		end

		# speed_to target_speed, 1
	end

	# chooses deccel required to reach <target_speed>, from
	# available deccel rates
	def deccelerate_to(target_speed, max_slow=Kinetic::Accel::SlowFast)
		delta = target_speed - @speed
		if delta <= Kinetic::Accel::EmergencyBreak && max_slow <= Kinetic::Accel::EmergencyBreak
			Kinetic::Accel::EmergencyBreak
		elsif delta <= Kinetic::Accel::SlowFast && max_slow <= Kinetic::Accel::SlowFast
			Kinetic::Accel::SlowFast
		elsif delta <= Kinetic::Accel::SlowNormal && max_slow <= Kinetic::Accel::SlowNormal
			Kinetic::Accel::SlowNormal
		elsif delta <= Kinetic::Accel::SlowSlow && max_slow <= Kinetic::Accel::SlowSlow
			Kinetic::Accel::SlowSlow
		else
			Kinetic::Accel::NoAccel
		end

		# speed_to target_speed, -1, max_slow
	end

	# not used
	def speed_to(target_speed, sign, max_accel=sign*Kinetic::Accel::FastAccel)
		delta = target_speed - @speed
		return Kinetic::Accel::NoAccel  if delta == 0 || delta / delta.abs != sign
		accels = Kinetic::Accel.constants_values.select {|x| (x <=> 0) == sign}
		accels.sort_by! {|x| -x.abs}

		accels.each {|accel|
			return accel if delta.abs >= accel.abs && accel <= max_accel
		}
		return Kinetic::Accel::NoAccel
	end

	# leaving junction, asking Mission
	# for new instructions.
	def prepare_to_leave_junction
		Log.debug "prepare_to_leave_junction"
		begin
			next_op = @driving_instructions.shift

			if next_op.is_a?(Road) && @driving_position.outgoing_roads.include?(next_op)
				turn_to next_op
				return
			end
			
			if next_op == :ParkNext
				Log.full "Parking at #{in_junction}"	
			else
				Log.warn "Unknown command #{next_op.inspect}"
			end
			park_here
		end while !@driving_instructions.empty?
		# the loop checks for returning instructions from Mission, 
		# in case of a returning Mission
	end

	def turn_to(road)
		Log.full "#{map_name}> Truning to #{road}"
		@driving_position = road
		@distance = Kinetic::Metric.zero
		@speed = @speed_before_junction
		@driving_state = :Normal
	end

	def end_road
		Log.full "Road ended."
		approaching on_road.end_junction  if @speed >= distance_left_on_road

		@speed_before_junction = @speed
		@driving_position = on_road.end_junction
		@speed = Kinetic::SpeedOnJunction
		@distance = 0
		@driving_state = :Junction
	end

	# reports the position and the distance to the map
	def report_driving_position_and_status
		@map.update_car_position self, @driving_position, distance_left_on_object
	end

	def distance_left_on_object
		on_road ? distance_left_on_road : Kinetic::JunctionTurnTime -  @distance
	end

	def distance_left_on_road
		on_road ? ( on_road.length - @distance ) : 0
	end

	def on_road
		@driving_position.is_a?(Road) ? @driving_position : nil
	end

	def in_junction
		@driving_position.is_a?(Junction) ? @driving_position : nil
	end

	def park_here
		Log.full "#{map_name}> Parking here"
		@engine = :Parked
		@driving_state = :Normal
		report_stop
	end

	def crash_car(message)
		@crash_message = message
		Log.warn "Car #{map_name} Crashed: #{message}"
		@engine = :Crashed
		@driving_state = :NoState
		report_stop
	end

	# informs Mission on stopping
	def report_stop
		report_not_driving @engine, @driving_position
	end

	def remove_car_from_map
		@map.update_car_position self, nil, Kinetic::Metric.zero
	end
end
