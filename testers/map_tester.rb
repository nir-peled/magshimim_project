load 'testers/tester.rb'
load 'map.rb'
load 'junction.rb'
load 'road.rb'
load 'car.rb'

class MapTester < Tester

	def self.run_test
		puts "Start!"
		m = Map.new

		j1 = Junction.new GeoHelper::Position.new(1,1)
		j2 = Junction.new GeoHelper::Position.new(5,5)
		j3 = Junction.new GeoHelper::Position.new(6,6)

		c1 = Car.new(4, 'Juan')
		m.add_car(c1)

		#m.print_map
		m.add_mission c1, j1, j3
		c1.go!&.join
	end
end

MapTester.run_test