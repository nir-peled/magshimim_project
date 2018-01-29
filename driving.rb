load 'kinetic_parameters.rb'

module Driving

	def init_driving(junction)
		@driving_instructions = []
		@position = junction
		@distance = 0
		@engine = 'Parked'
		@driver = Thread.new { driver_control }
		return @driver
	end

	def stop_driving
		@driver.kill
	end
	
	def drive_on(road)
		Log.full ">> drive_on adding #{road} to driving_instructions"
		@driving_instructions << road
		
		if @engine == 'Parked'
			@speed = KineticParameters::SpeedOnJunction
			@engine = "Running"
		end
	end

	def park_at_next_junction
		@driving_instructions << "ParkNext"
	end

	def crashed
		@engine = 'Crashed'
		update_status true
	end

private

	def driver_control
		while true
			calc_position_and_status
			report_position_and_status
			sleep KineticParameters::DriverControlLoopDelay
		end
	end

	def calc_position_and_status
		return if @engine != 'Running'
		Log.full ">> ===== calc_position_and_status. Pos:#{@position}. Speed:#{@speed}. Distance: #{@distance} Engine: #{@engine}"
		@distance += @speed

		if on_road
			change_position_on_road
		else # on junction
			prepare_to_leave_junction if @distance == KineticParameters::JunctionTurnTime
		end
	end

	def change_position_on_road
		if distance_left_on_road == 0
			return end_road
		elsif distance_left_on_road <= @speed
			# arriving next tick
			Log.full ".. sending approaching #{on_road.end_junction}"
			set_speed_by_road
			approaching on_road.end_junction
		end
	end

	def prepare_to_leave_junction
		next_op = @driving_instructions.shift
		if next_op.is_a?(Road) && @position.outgoing_roads.include?(next_op)
			Log.full "Truning to #{next_op}"
			@position = next_op
			@distance = 0
			set_speed_by_road
			return
		end
		
		if next_op == 'ParkNext'
			Log.full "Parking at #{in_junction}"	
		else
			Log.warn "Unknown command #{next_op}"
		end
		park_here	
	end

	def end_road
		Log.full "Road ended."
		@position = on_road.end_junction
		@speed = KineticParameters::SpeedOnJunction
		@distance = 0
		
		park_here if @driving_instructions.first == "ParkNext"
	end

	def distance_left_on_road
		on_road.length - @distance
	end

	def set_speed_by_road
		@speed = ( distance_left_on_road >= on_road.speed_limit ? on_road.speed_limit : distance_left_on_road )
	end


	def report_position_and_status
		# @map.update self
		# report_not_driving @engine, @position if is_status_change && @engine != 'Running'
	end

	def on_road
		@position.is_a?(Road) ? @position : nil
	end
	def in_junction
		@position.is_a?(Junction) ? @position : nil
	end

	def park_here
		Log.full "Parking here"
		@engine = 'Parked'
		@distance = 0
		@speed = 0
		report_not_driving @engine, @position
	end
end