
module Kinetic
	DriverControlLoopDelay = 0.1
	JunctionTurnTime = 3
	SpeedOnJunction = 1
	SpeedDelta = 0.01
	JunctionEnterSpeed = 1

	module Accel
		EmergencyBreak = -2
		SlowDown = -1
		NoAccel = 0
		Normal = 1
		FastAccel = 2
	end

	def self.up_accel(accel)
		accels = Accel.constants
		accel_index = accels.index {|const| Accel.const_get(const) == accel }
		if accel == Accel.const_get(accels.last)
			accel
		else
			Accel.const_get accels[accel_index + 1]
		end
	end

	def self.speed_lower(speed, limit)
		limit - speed > SpeedDelta
	end

	def self.speed_close(speed, limit)
		(limit - speed).abs < SpeedDelta
	end
end
