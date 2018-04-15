
module MapGenerator
	def self.create_map(game_map, junctions, roads, cars)
		junctions_by_id = add_junctions game_map, junctions
		add_roads game_map, roads, junctions_by_id
		add_cars game_map, cars, junctions_by_id
	end

	private
	def self.add_junctions(game_map, junctions)
		# Hash[junctions.map {|e| [e[:id], game_map.add_junction GeoHelper::Position.new(e[:x], e[:y])] }]
		junctions_by_id = {}
		junctions.each { |e|
			junctions_by_id[e[:id]] = game_map.add_junction GeoHelper::Position.new(e[:x], e[:y])
		}
		junctions_by_id
	end

	def self.add_roads(game_map, roads, junctions_by_id)
		roads.each { |e| 
			game_map.create_road junctions_by_id[e[:start_j]], junctions_by_id[e[:end_j]], e[:speed_limit]
		}
	end

	def self.add_cars(game_map, cars, junctions_by_id)
		cars.each { |e|
			start_junction = junctions_by_id[e[:start_j]]
			end_junction = junctions_by_id[e[:end_j]]

			car = game_map.create_car start_junction.position, e[:length]
			game_map.add_mission car, start_junction, end_junction
		}
	end
end
