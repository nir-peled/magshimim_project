load 'map_dynamic_object.rb'
load 'car_mission.rb'

class Car < MapDynamicObject

	attr_reader :length, :status, :name, :id

	include CarMission

	module Statuses
		ACTIVE = :ACTIVE
		INACTIVE = :INACTIVE
		CRASHED = :CRASHED
	end

	def initialize(length, name=nil)
		@length = length
		@status = Statuses::INACTIVE
		@name = name
	end


end
