require 'set'

module RouteFinder
	def self.find_shortest_path(src_node, dst_node)
		nodes_checked = Set.new
		nodes_to_visit = Set.new([src_node])
		route_backtrack = {src_node => nil}

		cost_until_node = {src_node => 0}
		route_cost_estimation = { src_node => huristic_cost_estimate(src_node, dst_node) }
		cost_until_node.default = route_cost_estimation.default = Float::INFINITY

		while !nodes_to_visit.empty?
			current_node = nodes_to_visit.min_by {|node| route_cost_estimation[node] }
			return rebuild_route current_node, route_backtrack if current_node == dst_node

			nodes_to_visit.delete current_node
			nodes_checked << current_node

			current_node.neighbors.each { |neighbor| 
				next if nodes_checked.include? neighbor
				nodes_to_visit << neighbor unless nodes_to_visit.include? neighbor # unless not needed if using set

				optional_neighbor_cost = cost_until_node[current_node] + current_node.cost_to(neighbor)
				if optional_neighbor_cost < cost_until_node[neighbor]
					route_backtrack[neighbor] = current_node
					cost_until_node[neighbor] = optional_neighbor_cost
					route_cost_estimation[neighbor] = cost_until_node[neighbor] + huristic_cost_estimate(neighbor, dst_node)
				end
			}
		end
		return []
	end

	private

	def self.huristic_cost_estimate(src_node, dst_node)
		src_node.distance_to(dst_node) / Road::SpeedLimit::MaxSpeedLimit
	end
	
	def self.rebuild_route(dst_node, backtrack)
		route = []
		current_node = dst_node
		prev_node = backtrack[dst_node]
		while !prev_node.nil?
			route.unshift prev_node.road_to current_node
			current_node, prev_node = prev_node, backtrack[prev_node]
		end
		route
	end
end
