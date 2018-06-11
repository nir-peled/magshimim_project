load 'map_dynamic_object.rb'
load 'mission.rb'
load 'driving.rb'

class Car < MapDynamicObject

	attr_reader :length, :name

	include Driving
	include Mission

	def initialize(position, car_length=0, opt={})
		super position, opt
		@length = car_length
	end

	# the layer is greater in order to be above
	# junctions or roads
	def draw
		@image = ObjectImage.get_image(:car, accel_to_image_index)
		super 2
	end

	def as_list_line
		"#{to_s.ljust(6,' ')}|#{length.to_s.center(8,' ')}| #{status}"
	end

	def Car.list_header
		"\nCars\n=========\nname  | Length | Status   | Mission |Position\n------------------------------------"
	end

	private

	def accel_to_image_index
		case accel
		when Kinetic::Accel::NoAccel
			:green_car
		when Kinetic::Accel::NormalAccel, Kinetic::Accel::FastAccel
			:orange_car
		when Kinetic::Accel::SlowNormal, Kinetic::Accel::SlowFast
			:blue_car
		when Kinetic::Accel::EmergencyBreak
			:red_car
		end
	end
end
