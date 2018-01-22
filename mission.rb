module Mission

	module Statuses
		class Active; end
		class Inactive; end
		class Driving < Active; end
		class Parked < Active; end
		class Crashed < Active; end
		class Finishing < Driving; end
		class Aborting < Driving; end
		class Completed < Active; end
	end

	class MissionError < StandardError; end
	class ImpossibleActionForStatus < MissionError; end
	class LostMyWay < MissionError; end

	class Route
		def initialize(_route)
			@route = _route
			@leg = nil
		end

		def next_road
			if @leg.nil?
				@leg = 0
			else
				@leg += 1
			end
			current_road
		end

		def current_road
			@route[@leg]
		end
	end

	def set_mission _map, _from_junction, _to_junction, and_back=false, recurr=false 
		Log.info "Setting mission for #{name}. #{_map.class}"
		if @status && @status <= Statuses::Active
			raise ImpossibleActionForStatus.new("This car in on a mission. Abort it first.")
		end

		@map = _map
		@from_junction = _from_junction
		@to_junction = _to_junction
		@status = Statuses::Active

	rescue MissionError => e 
		Log.warn e.message
	ensure
		Log.full "<< set_mission; status=#{@status}"
	end

	def go!
		Log.full ">> Go! status is #{@status}"
		raise ImpossibleActionForStatus.new("Cannot 'go!' when #{@status}") unless @status == Statuses::Active

		# Get route
		@route = Route.new @map.route_for(@from_junction, @to_junction)

		driver_thread = init_driving(@from_junction)
		if driver_thread
			@status = Statuses::Driving
		else
			raise MissionError.new("Driver error. Could not start driving.")
		end

		road = @route.next_road
		Log.full ".. drive on #{road}"
		drive_on road
		return driver_thread
	rescue MissionError => e
		Log.warn e.message
	ensure
		Log.full "<< go! status=#{@status}"
	end

	def approaching(junction)
		Log.full ">> approaching #{junction}"
		unless status <= Statuses::Driving
			raise ImpossibleActionForStatus.new("'approach' called in #{status}")
		end

		if junction == to_junction
			Log.full " .. park_at_next_junction!"
			park_at_next_junction 
		else
			if !@route.current_road.connected?(junction)
				raise LostMyWay.new("Junction #{junction} is not on this route.")
			end

			next_road = @route.next_road
			if !next_road.connected?(junction)
				raise LostMyWay.new("Route does not continue from #{junction}")
			end

			drive_on next_road
		end
	rescue MissionError => e 
		Log.warn e.message
		park_at_next_junction
		status = Statuses::Aborting
	ensure
		Log.full "<< approaching" 
	end

	def report_not_driving status, position
		if status == 'Parked'
			parked_at position
		else
			crashed_at position
		end
	end

private 

	def parked_at junction
		if junction==@to_junction
			Log.full "#{map_name} had reached its destination"
			@status = Statuses::Completed
			stop_driving
		end
	end

	def crashed_at position
		unless status < Statuses::Driving
			raise ImpossibleActionForStatus.new("Cannot 'crash!' when #{status}")
		end

		# do crash actions
		status == Statuses::Crashed
	rescue MissionError => e 
		Log.warn e.message
	end

	attr :map, :from_junction, :to_junction, :status, :route
end