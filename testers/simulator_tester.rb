load 'testers/tester.rb'
load 'simulator.rb'

class SimulatorTester < Tester
	def self.run_test
		puts "Start!"
		sim = Simulator.new
		sim.start_running
	end
end
Thread.abort_on_exception = true
SimulatorTester.run_test
