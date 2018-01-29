
class Tester
	private
	
	def self.run_action name=nil
		puts "Running #{name}" if name
		yield
	rescue StandardError => e
		puts "!! Error: #{e.message}"
	end
end
