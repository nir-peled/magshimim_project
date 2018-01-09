module Driving

	DriverControlLoopDelay = 1

	def init_driving
		@driving_instructions = []
		@position = 0
		@driver = Thread.new { driver_control }
		return @driver
	end

	def stop_driving
		@driver.kill
	end
	
	def drive_on road
		Log.full ">> drive_on adding #{road} to driving_instructions"
		@driving_instructions << road
		Log.full "<< drive_on"
	end

	def park_at_next_junction;
		@driving_instructions << "Park"
	end

	def driver_control
		while true
			Log.full "tik..."
			update_position
			Log.full "tok..."
			#update_status
			sleep DriverControlLoopDelay
		end
	end

	def update_position
		Log.full ">> update_position. Pos:#{@position}. On road? #{on_road?} Road is #{current_road}"
		@position += 1 if on_road?

		if @position == 8
			Log.full ".. sending approaching #{current_road.end_junction}"
			approaching current_road.end_junction
		end
		if @position == 9
			Log.full " .. on 9 removing road from queue"
		end
		if @position == 10
			Log.full " .. on 10! Road ended."
			Log.full " .. removing #{current_road}"
			@driving_instructions.shift
			@position = 0
			unless on_road?
				Log.full " .. in junction #{current_junction}. Removing from queue."
				@driving_instructions.shift
			end
		end
	end

	def on_road?
		@driving_instructions.first.is_a? Road
	end
	def on_junction?
		@driving_instructions.first.is_a? Junction
	end
	def current_road
		if on_road?
			@driving_instructions.first
		else
			nil
		end
	end
	def current_junction
		if on_junction?
			@driving_instructions.first
		else
			nil
		end
	end

end