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

		run_action {m.connect_junctions j1, j2, Road::SpeedLimit::MaxSpeedLimit, two_way:true}
		run_action {m.connect_junctions j2, j3, Road::SpeedLimit::Normal, two_way:true}

		c1 = m.add_car(j1.position, 4, :map_name=> "Juan")

		m.print_map
		run_action {m.add_mission c1, j1, j3 }
		# c1.go!&.join
		trd = c1.go!
		trd.join if !trd.nil?
	end
end

AccelTester.run_test