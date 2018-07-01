require 'thread' # mutex

# the Log class
# prints to the log at different levels
class Log

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
		const_val = Level.const_get(const)
		define_singleton_method(const.downcase) { |message|
			self.write_log message, const_val
			@@message_num[Level::Desc[const_val]] += 1
		}  if const != :Blank && const != :Desc
	}

	@@log_file = nil
	@@to_terminal = true
	@@level = Level::BLANK
	@@include_time = true
	@@message_num = Hash.new { |hash, key| hash[key] = 0 }
	@@log_mutex = Mutex.new
	def self.init(file = nil, to_terminal = true, level = @@level)
		if file
			file_to_open = file
		else
			file_to_open = 'traffic_simulator.log'
		end
		@@log_file = File.open(file_to_open, "w")
		@@to_terminal = to_terminal
		@@level = level
		@@include_time = true
		@@message_num = Hash.new { |hash, key| hash[key] = 0 }

		self.error "Log started with level #{@@level}"
	end

	def self.set_level(_level); @@level = _level; end
	def self.include_time; @@include_time; end
	def self.include_time=(flag); @@include_time = flag; end

	def self.report_messages
		return if @@level > Level::INFO
		write_log "Log Report:", Level::INFO
		@@message_num.each {|log_level, num| write_log "#{log_level.to_s} - #{num} messages", Level::INFO }
	end

	def self.close_log
		report_messages
		error "Log terminated"
		@@log_file.close
		@@log_file = nil
	end

	private

	def self.write_log(message, level)
		if message.respond_to? :each
			message.each {|m| self.write m, level}
		else
			self.write message, level
		end
	end

	def self.write(message, level)
		self.init if @@log_file.nil?
		return unless level >= @@level

		if level == Level::BLANK
			m = message
		else
			m = [Time.new, '('+Level::Desc[level]+')', message]
			m.shift if !@@include_time
			m = m.join(" ")
		end

		@@log_mutex.lock
		@@log_file.puts m
		puts m if @@to_terminal
	ensure
		@@log_mutex.unlock  if @@log_mutex.owned?
	end
end
