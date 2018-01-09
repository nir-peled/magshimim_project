load 'map.rb'
load 'junction.rb'
load 'road.rb'
load 'car.rb'

class MapTester

	def self.run_test
		puts "Start!"
		m = Map.new

		j1 = Junction.new GeoHelper::Position.new(1,1)
		j2 = Junction.new GeoHelper::Position.new(5,5)
		j3 = Junction.new GeoHelper::Position.new(6,6)

		r1 = Road.new [j1,j2], 50

		m.add_road r1

		r2 = run_action {Road.new [j2,j3], 50}
		m.add_road r2

		c1 = Car.new(4, 'Juan')
		m.add_car(c1)

		#m.print_map
		m.add_mission c1, j1, j3
		c1.go!&.join
	end

private
	
	def self.run_action name=nil
		puts "Running #{name}" if name
		yield
	rescue StandardError => e
		puts "!! Error: #{e.message}"
	end
end

MapTester.run_test