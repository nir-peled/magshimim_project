load 'kinetic.rb'

module Driving

	def init_driving(junction)
		@driving_instructions = []
		@position = junction
		@distance = @speed_before_junction = @speed = @accel = 0
		@engine = :Parked
		@driver = Thread.new { driver_control }
		return @driver
	end

	def stop_driving
		@driver.kill
	end
	
	def drive_on(road)
		@driving_instructions << road	
		start_driving if @engine == :Parked
	end

	def park_at_next_junction
		@driving_instructions << :ParkNext
	end

	def crashed
		@engine = :Crashed
		update_status true
	end

private

	def driver_control
		while true
			calc_position_and_status
			report_position_and_status
			sleep Kinetic::DriverControlLoopDelay
		end
	end

	def start_driving
		Log.full "Starting to drive"
		@speed = 0
		@distance = Kinetic::JunctionTurnTime
		@engine = :Running
	end

	def calc_position_and_status
		return if @engine != :Running
		Log.full ">> ===== #{map_name}: Pos:#{@position}. Speed:#{@speed}. Distance: #{@distance}"
		@distance += @speed

		if on_road
			change_position_on_road
		else # on junction
			prepare_to_leave_junction if @distance == Kinetic::JunctionTurnTime
		end
	end

	def change_position_on_road
		crash_car "Moved over junction" if distance_left_on_road < 0
		if distance_left_on_road == 0
			end_road
		else
			calc_new_accel_and_speed
			approaching on_road.end_junction if distance_left_on_road <= @speed
		end
		
	end

	def calc_new_accel_and_speed
		if Kinetic.speed_lower(distance_left_on_road, @speed) || Kinetic.speed_close(distance_left_on_road, @speed)
			# arriving next turn
			if Kinetic.speed_lower Kinetic::JunctionEnterSpeed, @speed
				@accel = lower_speed_to Kinetic::JunctionEnterSpeed
			elsif Kinetic.speed_lower distance_left_on_road, @speed
				@accel = lower_speed_to distance_left_on_road
			else
				@accel = Kinetic::Accel::NoAccel
			end

			@accel = Kinetic.up_accel(@accel) if Kinetic.speed_lower @speed + @accel, distance_left_on_road 
		else
			if Kinetic.speed_lower @speed, on_road.speed_limit
				@accel = Kinetic::Accel::Normal
			else
				@accel = Kinetic::Accel::NoAccel 
			end
		end
		
		@speed += @accel
	end

	def prepare_to_leave_junction
		next_op = @driving_instructions.shift
		if next_op.is_a?(Road) && @position.outgoing_roads.include?(next_op)
			Log.full "Truning to #{next_op}"
			@position = next_op
			@distance = 0
			@speed = @speed_before_junction
			return
		end
		
		if next_op == :ParkNext
			Log.full "Parking at #{in_junction}"	
		else
			Log.warn "Unknown command #{next_op}"
		end
		park_here	
	end

	def end_road
		Log.full "Road ended."
		crash_car "Entered Junction with a high speed" if @speed > Kinetic::JunctionEnterSpeed
		@speed_before_junction = @speed
		@position = on_road.end_junction
		@speed = Kinetic::SpeedOnJunction
		@distance = 0
		
		park_here if @driving_instructions.first == :ParkNext
	end

	def distance_left_on_road
		on_road ? on_road.length - @distance : 0
	end

	# def set_speed_by_road
	# 	@speed = ( distance_left_on_road >= on_road.speed_limit ? on_road.speed_limit : distance_left_on_road )
	# end

	def crash_car(message)
		@crash_message = message
		Log.warn "Car Crashed: #{message}"
		@engine = :Crashed
		report_not_driving @engine, @position
	end

	def lower_speed_to(speed_limit)
		accel = @speed + Kinetic::Accel::SlowDown <= speed_limit ? Kinetic::Accel::SlowDown : Kinetic::Accel::EmergencyBreak
	end

	def report_position_and_status
		# @map.update self
		# report_not_driving @engine, @position if is_status_change && @engine != :Running
	end

	def on_road
		@position.is_a?(Road) ? @position : nil
	end
	def in_junction
		@position.is_a?(Junction) ? @position : nil
	end

	def park_here
		Log.full "Parking here"
		@engine = :Parked
		@distance = 0
		@speed = 0
		report_not_driving @engine, @position
	end
end