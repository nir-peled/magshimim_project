module Mission

	module Statuses
		ACTIVE = :ACTIVE
		INACTIVE = :INACTIVE
		DRIVING = :DRIVING
		CRASHED = :CRASHED
	end

	def set_mission(from_junction, to_junction)
		if status==Statuses::INACTIVE
			start_junction = from_junction
			end_junction = to_junction
			status = Statuses::ACTIVE
		else
			Log.warn "This car in on a mission. Abort it first."
		end

	def go! 
		if status==Statuses::ACTIVE
			# Start driving
			status = Statuses::DRIVING
		else
			Log.warn "Cannot 'go!' when #{status}"
		end
	end

	def crash!
		if status==Statuses::DRIVING
			# do crash actions
			status == Statuses::CRASHED
		else
			Log.warn "Cannot 'crash!' when #{status}"
		end
	end

private 
	attr :start_junction, :end_junction, :status, :route, :current_road, :current_distance
end