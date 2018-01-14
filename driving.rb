module Driving

	DriverControlLoopDelay = 1

	def init_driving junction
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
	
	def drive_on road
		Log.full ">> drive_on adding #{road} to driving_instructions"
		@driving_instructions << road
		@engine = "Running" if @engine=='Parked'
	end

	def park_at_next_junction;
		@driving_instructions << "ParkNext"
	end

	def crashed
		@engine = 'Crashed'
		update_status true
	end

private

	def driver_control
		while true
			is_status_change = calc_position_and_status
			report_position_and_status is_status_change
			sleep DriverControlLoopDelay
		end
	end

	def calc_position_and_status
		Log.full ">> ===== calc_position_and_status. Pos:#{@position}. Distance: #{@distance} Engine: #{@engine}"
		is_status_change = false
		@distance += 1 if @engine=='Running'

		if on_road
			if @distance == 9
				Log.full ".. sending approaching #{on_road.end_junction}"
				approaching on_road.end_junction
			end
			if @distance == 10
				Log.full " .. on 10! Road ended."
				@position = on_road.end_junction
				@distance = 0
			end
		else
			if @distance == 2
				Log.full "Preparing to leave #{in_junction}"
				if @driving_instructions.empty?
					Log.warn "Dunno where to go. Parking at #{in_junction}"
					@distance = 0
					@engine = 'Parked'
					is_status_change = true
				else
					next_op = @driving_instructions.shift
					if next_op.is_a?(Road) && @position.outgoing_roads.include?(next_op)
						Log.full "Truning to #{next_op}"
						@position = next_op
						@distance = 0
					elsif next_op=='ParkNext'
						Log.full "Parking at #{in_junction}"
						@distance = 0
						@engine = 'Parked'
						is_status_change = true
					else
						Log.warn "Unknown command #{next_op}"
						@engine = 'Parked'
						is_status_change = true
						@distance = 0
					end
				end
			end
		end
		return is_status_change
	end

	def report_position_and_status is_status_change
		#@map.update self
		if is_status_change && @engine!='Running'
			report_not_driving @engine, @position
		end
	end

	def on_road
		@position.is_a?(Road) ? @position : nil
	end
	def in_junction
		@position.is_a?(Junction) ? @position : nil
	end

end