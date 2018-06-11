
module Driving
	def init_driving(junction)
		@driving_instructions = []
		@driving_position = junction
		@distance = rand(Kinetic::JunctionTurnTime.to_i)
		@speed =  Kinetic::SpeedOnJunction
		@speed_before_junction = Kinetic::Metric.zero
		@engine = :Parked
		@driver = Thread.new { driver_control } if @driver.nil?
		@driving_state = :NoState
		@crashed = false
		
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
	
	def drive_on(road)
		@driving_instructions << road
		start_driving if @engine == :Parked
	end

	def park_at_next_junction
		@driving_instructions << :ParkNext
	end

	def crashed(message)
		@crashed = true
		@crash_message = message
	end

	protected
	attr :speed
	attr :distance
	attr :accel

	private
	def start_driving
		Log.full "Starting to drive"
		@driving_state = :Normal
		@engine = :Running
	end

	def driver_control
		while !@crashed
			calc_driving_position_and_status
			report_driving_position_and_status
			sleep Kinetic::DriverControlLoopDelay
		end
		crash_car @crash_message
	rescue StandardError => e
		Log.error "#{map_name} > #{e.class}: #{e.message}"
		crash_car e.message
		# raise e
	rescue Exception => e
		Log.error "#{map_name} > #{e.class}: #{e.message}"
		raise e
	end

	def calc_driving_position_and_status
		return if @engine != :Running
		@distance += @speed
		Log.full ">> ===== #{map_name}: Pos:#{@driving_position}. Speed:#{@speed}. Distance: #{@distance} (#{distance_left_on_road})"

		if on_road
			change_driving_position_on_road
		else # on junction
			prepare_to_leave_junction if @distance == Kinetic::JunctionTurnTime
		end
	end

	def change_driving_position_on_road
		if distance_left_on_road <= Kinetic::JunctionRadius
			crash_car "enters junction too fast"  if @speed > Kinetic::MaxJunctionEnterSpeed
			end_road
		else
			if distance_left_on_road > @speed || @speed > Kinetic::MaxJunctionEnterSpeed
				# may be able to accelerate || too fast
				@speed += calc_new_accel
			end
		end
	end

	def calc_new_accel
		traffic = find_road_traffic
		
		junction_accel = calc_junction_accel
		car_accel = calc_car_accel(traffic)

		@accel = [junction_accel, car_accel].compact.min
	ensure
		Log.full "#{map_name}> new accel: #{@accel}."
	end

	def find_road_traffic
		@map.traffic(on_road, @distance)
	end

	def calc_junction_accel
		occupation_time = @map.junction_occupation_time(on_road.end_junction)
		junction_gap = deccel_distance_gap
		if junction_gap / Kinetic::MaxJunctionEnterSpeed <= occupation_time
			junction_gap = distance_left_on_road - Kinetic::JunctionRadius - Kinetic.distance_to_stop(@speed)
			calc_accel_to_junction junction_gap, 0
		else
			calc_accel_to_junction junction_gap 
		end
	end

	def calc_accel_to_junction(gap, min_speed=Kinetic::MaxJunctionEnterSpeed)
		@driving_state = :Normal  if @speed < min_speed

		if gap >= 0
			if @driving_state == :Normal && gap > Kinetic::JunctionApproachDistance
				accelerate_to [on_road.speed_limit, distance_left_on_road].min
			else
				@driving_state = :Slowing
				deccelerate_to min_speed, Kinetic::Accel::SlowNormal
			end
		else
			@driving_state = :Slowing
			deccelerate_to min_speed
		end
	end

	def calc_car_accel(traffic)
		return nil  if traffic.nil? || (traffic.is_a?(Array) && traffic.empty?)

		other, other_distance = traffic
		car_gap = car_distance_gap(other, other_distance)
		calc_accel_to_car(car_gap, other.speed)
	end

	def deccel_distance_gap
		distance_left_on_road - Kinetic.deccel_distance_for_approach(@speed)
	end

	def car_distance_gap(other, other_distance)
		other_distance_to_stop = other_distance + Kinetic.emergency_stop_distance(other.speed)
		my_distance_to_stop = @distance + Kinetic.emergency_stop_distance(speed)

		other_distance_to_stop - my_distance_to_stop - other.length
	end

	def calc_accel_to_car(gap, other_speed)
		if gap > Kinetic::SufficientCarGap
			Kinetic::Accel::FastAccel
		elsif gap > Kinetic::MinimalCarGap
			Kinetic::Accel::SlowSlow
		else
			deccelerate_to other_speed, Kinetic::Accel::EmergencyBreak
		end
	end

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

	def prepare_to_leave_junction
		Log.debug "prepare_to_leave_junction"
		begin
			next_op = @driving_instructions.shift
			Log.debug "next_op = #{next_op}"
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
	end

	def turn_to(road)
		Log.full "Truning to #{road}"
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

	def distance_left_on_road
		on_road ? ( on_road.length - @distance ) : 0
	end

	def lower_speed_to(speed_limit)
		if @speed + Kinetic::Accel::SlowDown <= speed_limit
			Kinetic::Accel::SlowDown
		else
			Kinetic::Accel::EmergencyBreak
		end
	end

	def report_driving_position_and_status
		@map.update_car_position self, @driving_position, @distance
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
		# @distance = 0
		# @speed = 0
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

	def report_stop
		report_not_driving @engine, @driving_position
	end

	def remove_car_from_map
		@map.update_car_position self, nil, Kinetic::Metric.zero
	end
end
