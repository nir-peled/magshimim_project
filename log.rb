class Log
	@@log_file = nil
	@@to_terminal = true
	@@level = nil

	module Level
		BLANK = 0
		FULL = 1
		INFO = 2
		WARNING = 3
		ERROR = 4

		Desc = {BLANK => "", FULL => "Full", INFO => "Info", WARNING => "Warn", ERROR => "Err"}
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

	def self.full (message) self.write_log message, Level::FULL; end

	def self.info (message) self.write_log message, Level::INFO; end

	def self.warn (message) self.write_log message, Level::WARNING; end

	def self.error (message) self.write_log message, Level::ERROR; end

	def self.blank (message) self.write_log message, Level::BLANK; end

private

	def self.write_log message, level
		if message.respond_to? :each
			message.each {|m| self.write m, level}
		else
			self.write message, level
		end
	end

	def self.write message, level
		self.init if @@log_file.nil?
		return unless level >= @@level

		if level==Level::BLANK
			m = message
		else
			m = [Time.new, '('+Level::Desc[level]+')', message].join(" ")
		end

		@@log_file.puts m
		puts m if @@to_terminal
	end

end