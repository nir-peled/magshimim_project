class Log
	@@log_file = nil
	@@to_terminal = true
	@@level = nil
	@@include_time = true

	module Level
		BLANK = 0
		DEBUG = 1
		FULL = 2
		INFO = 3
		WARN = 4
		ERROR = 5

		Desc = {BLANK => "", DEBUG => "Debug", FULL => "Full", INFO => "Info", WARN => "Warn", ERROR => "Err"}
	end
	Level.constants.each { |const|
		define_singleton_method(const.downcase) { |message|
			self.write_log message, Level.const_get(const)
		} if const != :Blank && const != :Desc
	}

	def self.init(file = nil, to_terminal = true, level = Level::BLANK)
		if file
			file_to_open = file
		else
			file_to_open = 'traffic_simulator.log'
		end
		@@log_file = File.open(file_to_open, "w")
		@@to_terminal = to_terminal
		@@level = level
		@@include_time = true

		self.error "Log started with level #{@@level}"
	end

	def self.include_time; @@include_time; end
	def self.include_time=(flag); @@include_time = flag; end

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

		if level == Level::BLANK
			m = message
		else
			m = [Time.new, '('+Level::Desc[level]+')', message]
			m.shift if !@@include_time
			m = m.join(" ")
		end

		@@log_file.puts m
		puts m if @@to_terminal
	end
end
