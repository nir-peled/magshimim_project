
# this module represents a Car's
# Mission, namely it's start and end junctions
# and it's route. It communicate with Driving
# and gives it instructions
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

		def print_route
			Log.debug "@route = #{@route.inspect}"
			str = @route.first.start_junction.to_s + ","
			str += @route.map {|road| road.to_s + "," + road.end_junction.to_s }.join(",")
			Log.full str
		end
	end

	def set_mission(_map, _from_junction, _final_junction, _and_back=false, _recurr=false) 
		if @status && @status <= Statuses::Active
			raise ImpossibleActionForStatus.new("This car in on a mission. Abort it first.")
		end

		@map = _map
		@from_junction = _from_junction
		@final_junction = _final_junction
		@status = Statuses::Active
		@and_back = _and_back
		@recurr = _recurr

	rescue MissionError => e 
		Log.warn e.message
	end

	def go!
		Log.full ">> Go! status is #{@status}"
		raise ImpossibleActionForStatus.new("Cannot 'go!' when #{@status}") unless @status == Statuses::Active

		# Get route
		@route = Route.new @map.route_for(@from_junction, @final_junction)
		Log.full "route is: "
		@route.print_route


		@driver_thread = init_driving(@from_junction)  if @driver_thread.nil?
		if @driver_thread
			@status = Statuses::Driving
		else
			raise MissionError.new("Driver error. Could not start driving.")
		end

		road = @route.next_road
		Log.full ".. drive on #{road}"
		drive_on road
		return @driver_thread
	rescue MissionError => e
		Log.warn e.message
	end

	def force_finish
		status = Statuses::Inactive
		stop_driving
	end

	# used by Driving to inform about closing to junction, 
	# and to ask for new instructions
	def approaching(junction)
		Log.full ">> approaching #{junction}"
		unless status <= Statuses::Driving
			raise ImpossibleActionForStatus.new("'approach' called in #{status}")
		end
		
		Log.info "currnet junction = #{junction}, final_junction = #{final_junction}"
		if junction == final_junction
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

	# used by Driving to report stopping
	def report_not_driving(status, position)
		if status == :Parked
			parked_at position
		else
			crashed_at position
		end
	end

private 

	def parked_at(junction)
		Log.debug "parked_at #{junction.to_s} (@final_junction = #{@final_junction.to_s})"
		if junction == @final_junction
			Log.full "#{map_name} had reached its destination"
			complete_mission
		end
	end

	def crashed_at(position)
		raise ImpossibleActionForStatus.new("Cannot 'crash!' when #{status}") unless status <= Statuses::Driving

		# do crash actions
		Log.warn "Car #{map_name} crashed at #{position}"
		status == Statuses::Crashed
	rescue MissionError => e 
		Log.warn e.message
	ensure
		stop_driving
	end

	def complete_mission
		Log.full "#{map_name} > mission completed"
		@status = Statuses::Completed
		if @and_back
			@and_back = @recurr
			# if @recurr, continue looping. else, just this once
			go_back
		else
			stop_driving
		end
	end

	def go_back
		@status = Statuses::Active
		@from_junction, @final_junction = @final_junction, @from_junction
		go!
	end

	attr :map, :from_junction, :final_junction, :status, :route
end
