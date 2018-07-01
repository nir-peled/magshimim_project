
# this is the Kinetic module
# It keeps every kinetic constant, 
# and the functions related to physics. 
# It includes the Metric class, which wraps
# floats and compares by-delta
module Kinetic
	# compare-by-delta float class
	class Metric < Numeric
		def initialize(x)
			@float = x.to_f.round(3)
		end
		MetricDelta = 0.05
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

	# this includes the accel and deccel
	# rates available in this project
	module Accel
		EmergencyBreak = Metric.new(-1.0)
		SlowFast = Metric.new(-0.6)
		SlowNormal = Metric.new(-0.3)
		SlowSlow = Metric.new(-0.1)
		NoAccel = Metric.new(0)
		SlowAccel = Metric.new(0.2)
		NormalAccel = Metric.new(0.3)
		FastAccel = Metric.new(0.6)
	end

	# time for a single tick
	DriverControlLoopDelay = Metric.new(0.1)
	# ticks to turn in a junction
	JunctionTurnTime = Metric.new(2.0)
	SpeedOnJunction = Metric.new(1.0)

	# maximum speed to enter a junction without
	# crashing
	MaxJunctionEnterSpeed = Metric.new(0.5)
	# the junction's radius, from which cars are considered
	# inside it
	JunctionRadius = Metric.new(0.1)
	# the distance from a junction from which cars should
	# optimmaly be at junction entry speed
	JunctionApproachDistance = Metric.new(1.0)
	# the minimal gap to keep between cars
	MinimalCarGap = Metric.new(1.0)
	# a sufficient gap between cars to accelerate
	SufficientCarGap = 3 * MinimalCarGap
	JunctiocVisibleGap = 2 * JunctionApproachDistance

	# physical functions

	# the time to reach <target_speed> from <speed> at <accel>
	def self.time_to_accel(speed, target_speed, accel)
		((target_speed - speed) / accel).ceil
	end

	# the time to reach junction entry speed at <accel> (optimmaly SlowNormal)
	def self.time_to_junction_speed(speed, accel=Accel::SlowNormal)
		time_to_accel speed, MaxJunctionEnterSpeed, accel
	end

	# the distance an object passes in constant accel
	# from <speed> to <target_speed>
	def self.constant_accel_distance(accel, speed, target_speed=0)
		ticks = time_to_accel(speed, target_speed, accel)
		distance_passed = (speed * ticks) + (accel * (ticks ** 2.0) / 2.0)
		# distance_passed.ceil
		distance_passed
	end

	# the distance a car passes until it's speed is
	# to MaxJunctionEnterSpeed, while slowing at SlowNormal
	def self.deccel_distance_for_approach(speed)
		self.constant_accel_distance Accel::SlowNormal, speed, MaxJunctionEnterSpeed
	end

	# the distance it takes to stop in 
	# Accel::SlowNormal
	def self.distance_to_stop(speed)
		self.constant_accel_distance Accel::SlowNormal, speed # , 0
	end

	# the distance it takes to stop in 
	# Accel::EmergencyBreak
	def self.emergency_stop_distance(speed)
		self.constant_accel_distance Accel::EmergencyBreak, speed
	end
end

class Numeric
	def to_metric # a function to help handle Metric
		Kinetic::Metric.new self
	end
end
