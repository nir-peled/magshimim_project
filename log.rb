class Log
	@@log_file = nil
	@@to_terminal = true

	module Level
		FULL = :FULL
		BASIC = :BASIC
		WARNINGS = :WARNINGS
		Errors = :Errors
	end

	def self.init(file = nil, to_terminal = true)
		if file
			file_to_open = file
		else
			file_to_open = 'traffic_simulator.log'
		end
		@@log_file = File.open(file_to_open, "w")
		@@to_terminal = to_terminal
	end

	def self.full (message)
		self.write message, Level::FULL
	end

	def self.basic
		self.write message, Level::BASIC
	end

	def self.warn
		self.write message, Level::WARNINGS
	end

	def self.error
		self.write message, Level::Errors
	end

private
	def self.write(message, level)
		self.init if @@log_file.nil?
		m = "#{Time.new} (#{level}) #{message}"
		@@log_file.puts m
		puts m if @@to_terminal
	end

end