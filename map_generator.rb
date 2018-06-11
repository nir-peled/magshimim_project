
module MapGenerator
	def self.create_map(game_map, map_hash)
		junctions_by_id = add_junctions game_map, map_hash[:junctions]
		add_roads game_map, map_hash[:roads], junctions_by_id, map_hash[:road_always_back]
		add_cars game_map, map_hash[:cars], junctions_by_id
	end

	private
	def self.add_junctions(game_map, junctions)
		# Hash[junctions.map {|e| [e[:id], game_map.add_junction GeoHelper::Position.new(e[:x], e[:y])] }]
		junctions_by_id = {}
		junctions.each { |j|
			junctions_by_id[j[:id]] = game_map.add_junction GeoHelper::Position.new(j[:x], j[:y])
		}
		junctions_by_id
	end

	def self.add_roads(game_map, roads, junctions_by_id, always_back=false)
		roads.each { |road| 
			start_j, end_j = junctions_by_id[road[:start_j]], junctions_by_id[road[:end_j]]
			two_way = road[:and_back] || always_back
			game_map.connect_junctions start_j, end_j, speed_limit:road[:speed_limit], two_way:two_way
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
