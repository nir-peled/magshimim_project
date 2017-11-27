require 'set'

def find_shortest_path(graph, start_node, dest_node)
	nodes_to_visit = Queue.new
	nodes_to_visit << start_node

	prev_nodes = {start_node => nil}

	while !nodes_to_visit.empty?
		current_node = nodes_to_visit.pop
		
		return constuct_path dest_node, prev_nodes if current_node == dest_node

		current_node.neighbors.each { |neighbor| 
			unless prev_nodes.has_key? neighbor
				nodes_to_visit << neighbor
				prev_nodes[neighbor] = current_node
			end
		}
	end
	[]
end

def constuct_path(end_node, prev_nodes)
	path = [dest_node]

	prev_node = prev_nodes[dest_node]
	while !prev_node.nil?
		path.unshift prev_node
		prev_node = prev_node = prev_nodes[prev_node]
	end
	path
end
