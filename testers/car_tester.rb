load 'car.rb'

class CarTester

	class TestFailure < Exception; end

	def self.run_test
	
		car1 = nil

		begin
			car1 = Car.new
			raise TestFailure "Car initialized with no arguments"
		rescue ArgumentError => e
			
		end

		begin
			car1 = Car.new 5
		rescue StandardError => e
			raise TestFailure.new "Car not initialized with required arguments"
		end

		if car1.length!=5
			raise TestFailure "car length doesn't match"
		end

		begin
			car1 = Car.new 5, 'Joe'
			if car1.name!='Joe'
			raise TestFailure "car name doesn't match"
		end
			
		rescue StandardError => e
			raise TestFailure "Car not initialized with required arguments"
		end

		puts "All good!"
	rescue TestFailure => e
		puts e.message
	end

end