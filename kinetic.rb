
module Kinetic
	DriverControlLoopDelay = 0.1
	JunctionTurnTime = 3
	SpeedOnJunction = 1
	SpeedDelta = 0.01
	JunctionEnterSpeed = 2

	module Accel
		EmergencyBreak = -2
		SlowDown = -1
		NoAccel = 0
		Normal = 1
		FastAccel = 2
	end

	def self.speed_lower_than(speed, limit)
		limit - speed > SpeedDelta
	end

	def self.speed_close_to(speed, limit)
		(limit - speed).abs < SpeedDelta
	end
end
