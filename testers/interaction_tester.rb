load 'testers/tester.rb'
load 'simulator.rb'

class SimulatorTester < Tester
	def self.run_test
		Log.full "Start!"
		sim = Simulator.new
		sim.start_running
	end
end

Log.set_level(Log::Level::FULL)
Thread.abort_on_exception = true
SimulatorTester.run_test
