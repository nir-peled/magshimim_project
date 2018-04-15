
module Kinetic
	module Accel
		EmergencyBreak = -5
		SlowFast = -2
		SlowNormal = -1
		NoAccel = 0
		NormalAccel = 1
		FastAccel = 2
	end

	DriverControlLoopDelay = 0.1
	JunctionTurnTime = 3.0
	SpeedOnJunction = 1.0
	SpeedDelta = 0.01
	MaxJunctionEnterSpeed = 1.0
	JunctionRadius = 0.01
	JunctionApproachDistance = Accel::FastAccel

	

	def self.up_accel(accel)
		accels = Accel.constants
		accel_index = accels.index {|const| Accel.const_get(const) == accel }
		if accel == Accel.const_get(accels.last)
			accel
		else
			Accel.const_get accels[accel_index + 1]
		end
	end

	def self.constant_accel_distance(accel, speed, target_speed=0)
		ticks_to_travel = ((target_speed - speed) / accel).ceil
		distance_passed = (speed * ticks_to_travel) + (0.5 * accel * (ticks_to_travel ** 2.0))
		distance_passed.ceil
	end

	def self.deccel_distance_for_approach(speed)
		self.constant_accel_distance Kinetic::Accel::SlowNormal, speed, Kinetic::MaxJunctionEnterSpeed
	end

	class Speed < Numeric
		def initialize(x)
			@speed = x.to_f
		end

		def coerce(other)
			[self.class.new(other), self]
		end

		def <=>(other)
			if (@speed - other.to_f).abs < Kinetic::SpeedDelta 
				0
			elsif @speed > other.to_f
				1
			else
				-1
			end
		end

		def +(other)
			self.class.new(@speed + other.to_f)
		end

		def -(other)
			self.class.new(@speed - other.to_f)
		end

		def *(other)
			self.class.new(@speed * other.to_f)
		end

		def **(other)
			self.class.new(@speed ** other.to_f)
		end

		def /(other)
			self.class.new(@speed / other.to_f)
		end

		def to_i
			@speed.to_i
		end

		def ceil
			self.class.new(@speed.ceil)
		end
		
		def to_f
			@speed
		end

		def to_s
			@speed.to_s
		end
	end
end
