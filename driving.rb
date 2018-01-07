module Driving

	DriverControlLoopDelay = 0.2

	def init_driving
		@driver = Thread.new { driver_control }
		true
	end

	def stop_driving
		@driver.kill
	end
	
	def drive_on road

	end

	def park_at_next_junction; end

	def driver_control
		while true
			update_position
			update_status
			sleep DriverControlLoopDelay
		end
	end

	def update_position

	end


end