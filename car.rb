load 'map_dynamic_object.rb'
load 'mission.rb'
load 'driving.rb'

class Car < MapDynamicObject

	attr_reader :length, :name, :id
	alias :id :object_id

	include Driving
	include Mission

	def initialize(length, name=nil)
		@length = length
		@name = name
	end

	def to_s() @name; end

	def as_list_line
		"#{to_s.ljust(6,' ')}|#{length.to_s.center(8,' ')}| #{status}"
	end

	def Car.list_header
		"\nCars\n=========\nname  | Length | Status   | Mission |Position\n------------------------------------"
	end

end
