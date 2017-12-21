class Log
	@@log_file = nil
	@@to_terminal = true
	@@level = nil

	module Level
		BLANK = 0
		FULL = 1
		BASIC = 2
		WARNING = 3
		ERROR = 4

		DESC = {BLANK:"", FULL:"Full", BASIC:"Basic", WARNING:"Warn", ERROR:"Err"}
	end

	def self.init(file = nil, to_terminal = true, level = Level::BLANK)
		if file
			file_to_open = file
		else
			file_to_open = 'traffic_simulator.log'
		end
		@@log_file = File.open(file_to_open, "w")
		@@to_terminal = to_terminal
		@@level = level

		self.error "Log started with level #{@@level}"
	end

	def self.full (message) self.write message, Level::FULL; end

	def self.basic (message) self.write message, Level::BASIC; end

	def self.warn (message) self.write message, Level::WARNING; end

	def self.error (message) self.write message, Level::ERROR; end

	def self.blank (message) self.write message, Level::BLANK; end

private

	def self.write(message, level)
		self.init if @@log_file.nil?
		return unless level >= @@level

		m = "#{Time.new} (#{Levels::Desc[level]}) #{message}"

		@@log_file.puts m
		puts m if @@to_terminal
	end

end