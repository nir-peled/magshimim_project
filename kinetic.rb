
module Kinetic
	# compare-by-delta float class
	class Metric < Numeric
		def initialize(x)
			@float = x.to_f.round(3)
		end
		MetricDelta = 0.1
		INFINITY = Metric.new(Float::INFINITY)

		def self.zero; self.new(0.0); end

		def coerce(other)
			if other.is_a? Metric
				[other, self]
			else
				[Metric.new(other), self]
			end
		end

		def <=>(other)
			if (@float - other.to_f).abs < MetricDelta 
				0
			elsif @float > other.to_f
				1
			else
				-1
			end
		end

		def +(other)
			Metric.new(@float + other.to_f)
		end

		def -(other)
			Metric.new(@float - other.to_f)
		end

		def *(other)
			Metric.new(@float * other.to_f)
		end

		def **(other)
			Metric.new(@float ** other.to_f)
		end

		def /(other)
			Metric.new(@float / other.to_f)
		end

		def to_i
			@float.to_i
		end

		def ceil
			Metric.new(@float.ceil)
		end
		
		def to_f
			@float
		end

		def to_s
			@float.to_s
		end
		alias_method :inspect, :to_s

		def round(ndigits=4)
			@float.round(ndigits)
		end
	end

	module Accel
		EmergencyBreak = Metric.new(-1.0)
		SlowFast = Metric.new(-0.6)
		SlowNormal = Metric.new(-0.3)
		SlowSlow = Metric.new(-0.2)
		NoAccel = Metric.new(0)
		SlowAccel = Metric.new(0.2)
		NormalAccel = Metric.new(0.3)
		FastAccel = Metric.new(0.6)
	end

	# time for a single tick
	DriverControlLoopDelay = Metric.new(0.1)
	# ticks to turn in a junction (Time/Speed)
	JunctionTurnTime = Metric.new(2.0)
	SpeedOnJunction = Metric.new(1.0)
	# maximum speed to enter a junction without
	# crashing
	MaxJunctionEnterSpeed = Metric.new(0.5)
	JunctionRadius = Metric.new(0.1)
	JunctionApproachDistance = Metric.new(1.0)
	MinimalCarGap = Metric.new(5.0)
	SufficientCarGap = 3 * MinimalCarGap

	# returns the distance an object passes
	# in constant accel from <speed> to <target_speed>
	def self.constant_accel_distance(accel, speed, target_speed=0)
		ticks_to_travel = ((target_speed - speed) / accel).ceil
		distance_passed = (speed * ticks_to_travel) + (accel * (ticks_to_travel ** 2.0) / 2.0)
		# distance_passed.ceil
		distance_passed
	end

	# returns the distance a car passes to lower it's speed
	# to MaxJunctionEnterSpeed
	def self.deccel_distance_for_approach(speed)
		self.constant_accel_distance Accel::SlowNormal, speed, MaxJunctionEnterSpeed
	end

	# returns the distance it takes to stop in 
	# Accel::SlowNormal
	def self.distance_to_stop(speed)
		self.constant_accel_distance Accel::SlowNormal, speed # , 0
	end

	# returns the distance it takes to stop in 
	# Accel::EmergencyBreak
	def self.emergency_stop_distance(speed)
		self.constant_accel_distance Accel::EmergencyBreak, speed
	end
end

class Numeric
	def to_metric
		Kinetic::Metric.new self
	end
end
