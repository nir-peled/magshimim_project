
File.open("filtered_log.log", "w") { |file| 
	File.foreach("traffic_simulator.log") { |line| 
		file.puts line if ARGV.any? { |name| line.include? name }
	}
}

