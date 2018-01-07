module Mission

	module Statuses
		class Active; end
		class Inactive; end
		class Driving < Active; end
		class Parked < Active; end
		class Crashed < Active; end
		class Finishing < Driving; end
		class Aborting < Driving; end
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
			if !@leg
				@leg == 0
			else
				@leg += 1
			end
			current_road
		end

		def current_road
			@route[leg]
		end
	end

	def set_mission(_map, _from_junction, _to_junction)
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
		Log.info "<< set_mission; status=#{@status}"
	end

	def go!
		Log.info ">> Go! status is #{@status}"
		unless @status == Statuses::Active
			raise ImpossibleActionForStatus.new("Cannot 'go!' when #{@status}")
		end

		Log.info "Going!"
		# Get route
		@route = Route.new @map.route_for(@from_junction, @to_junction)

		# Start driving
		if init_driving
			@status = Statuses::Driving
		else
			raise MissionError.new("Driver error. Could not start driving.")
		end

		return  # to move down when checked
		
		drive_on @route.next_road

	rescue MissionError => e
		Log.warn e.message
	ensure
		Log.info "<< go! status=#{@status}"
	end

	def approaching(junction)
		unless status < Statuses::Driving
			raise ImpossibleActionForStatus.new("'approach' called in #{status}")
		end
		if junction==to_junction
			park_at_next_junction 
		else
			if !Route.current_road.junctions.include?(junction)
				raise LostMyWay.new("Junction #{junction} is not on this route.")
			end

			next_road = Route.next_road
			if !next_road.junctions.include?(junction)
				raise LostMyWay.new("My route does not continue from #{junction} is not on this route.")
			end

			drive_on next_road
		end
	rescue MissionError => e 
		Log.warn e.message
		park_at_next_junction
		status = Statuses::Aborting
	end

	def crashed
		unless status < Statuses::Driving
			raise ImpossibleActionForStatus.new("Cannot 'crash!' when #{status}")
		end

		# do crash actions
		status == Statuses::Crashed
	rescue MissionError => e 
		Log.warn e.message
	end

private 
	attr :map, :from_junction, :to_junction, :status, :route
end