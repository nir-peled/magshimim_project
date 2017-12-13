load 'map.rb'
load 'junction.rb'
load 'road.rb'

class MapTester

	def self.run_test
		m = Map.new

		j1 = Junction.new GeoHelper::Position.new(1,1)
		j2 = Junction.new GeoHelper::Position.new(5,5)

		r1 = Road.new [j1,j2], 50

		m.add_road r1

		r2 = Road.new [j1,j2], 50

		m.add_road r2

	end
end