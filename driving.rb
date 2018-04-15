load 'kinetic.rb'

module Driving
	def init_driving(junction)
		@driving_instructions = []
		@driving_position = junction
		@distance = 0.0
		@speed =  Kinetic::Speed.new(0.0)
		@speed_before_junction = Kinetic::Speed.new(0.0)
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
	def start_driving
		Log.full "Starting to drive"
		@speed = 0
		@distance = Kinetic::JunctionTurnTime
		@engine = :Running
	end

	def driver_control
		while true
			calc_driving_position_and_status
			report_driving_position_and_status
			sleep Kinetic::DriverControlLoopDelay
		end
	rescue StandardError => e
		Log.error "#{map_name} > #{e.class}: #{e.message}"
		crash_car e.message
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

	# compare distance by delta
	def change_driving_position_on_road
		if distance_left_on_road < Kinetic::JunctionRadius
			crash_car "enters junction too fast" if @speed > Kinetic::MaxJunctionEnterSpeed
			end_road
		else
			@speed += calc_new_accel
			approaching on_road.end_junction if distance_left_on_road <= @speed
		end
	end

	def calc_new_accel
		a = 0.0
		gap = deccel_distance_gap
		if gap >= 0
			if gap > Kinetic::JunctionApproachDistance
				a = accelerate_to on_road.speed_limit
			else
				if @speed > Kinetic::MaxJunctionEnterSpeed
					a = Kinetic::Accel::SlowNormal
				else
					a = Kinetic::Accel::NoAccel
				end
			end
		else
			a = Kinetic::Accel::SlowFast
		end
		a
	ensure
		# Log.debug "calc_new_accel: #{a}."
	end

	def deccel_distance_gap
		distance_left_on_road - Kinetic.deccel_distance_for_approach(@speed)
	end

	def accelerate_to(target_speed)
		delta = target_speed - @speed
		if delta >= Kinetic::Accel::FastAccel
			Kinetic::Accel::FastAccel
		elsif delta >= Kinetic::Accel::NormalAccel
			Kinetic::Accel::NormalAccel
		else
			Kinetic::Accel::NoAccel
		end
	end

	def prepare_to_leave_junction
		next_op = @driving_instructions.shift
		if next_op.is_a?(Road) && @driving_position.outgoing_roads.include?(next_op)
			Log.full "Truning to #{next_op}"
			@driving_position = next_op
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
		crash_car "Entered Junction with a high speed" if @speed > Kinetic::MaxJunctionEnterSpeed
		@speed_before_junction = @speed
		@driving_position = on_road.end_junction
		@speed = Kinetic::SpeedOnJunction
		@distance = 0
		
		park_here if @driving_instructions.first == :ParkNext
	end

	def distance_left_on_road
		on_road ? ( on_road.length - @distance ) : 0
	end

	# def set_speed_by_road
	# 	@speed = ( distance_left_on_road >= on_road.speed_limit ? on_road.speed_limit : distance_left_on_road )
	# end

	def crash_car(message)
		@crash_message = message
		Log.warn "Car Crashed: #{message}"
		@engine = :Crashed
		report_not_driving @engine, @driving_position
	end

	def lower_speed_to(speed_limit)
		accel = @speed + Kinetic::Accel::SlowDown <= speed_limit ?
			Kinetic::Accel::SlowDown : Kinetic::Accel::EmergencyBreak
	end

	def report_driving_position_and_status
		@map.update_distance_on_road self, on_road, @distance if on_road
		# report_not_driving @engine, @driving_position if is_status_change && @engine != :Running
	end

	def on_road
		@driving_position.is_a?(Road) ? @driving_position : nil
	end
	def in_junction
		@driving_position.is_a?(Junction) ? @driving_position : nil
	end

	def park_here
		Log.full "Parking here"
		@engine = :Parked
		@distance = 0
		@speed = 0
		report_not_driving @engine, @driving_position
	end
end
