load 'testers/tester.rb'
load 'map.rb'
load 'junction.rb'
load 'road.rb'
load 'car.rb'

class AccelTester < Tester

	def self.run_test
		puts "Start!"
		Log.include_time = false
		m = Map.new

		j1 = m.add_junction GeoHelper::Position.new(1,1)
		j2 = m.add_junction GeoHelper::Position.new(1,10)
		j3 = m.add_junction GeoHelper::Position.new(5,10)

		run_action {j1.connect_to j2, Road::SpeedLimit::MaxSpeedLimit}
		run_action {j2.connect_to j3, Road::SpeedLimit::Normal}

		c1 = Car.new(4, 'Juan')
		m.add_car(c1)

		m.print_map
		run_action {m.add_mission c1, j1, j3 }
		# c1.go!&.join
		trd = c1.go!
		trd.join if !trd.nil?
	end
end

AccelTester.run_test