require 'spec_helper'

class Car
  include Celluloid

  def initialize(start_speed = 10)
    @start_speed = start_speed
    @name = "Audi #{rand(10)}"
  end

  def drive(speed = 80)
    sleep [1, 1.5, 2].sample
    raise "You cannot drive at 100 or more." if speed >= 100
    { name: @name, current_speed: speed, start_speed: @start_speed }
  end

  def start_speed
    @start_speed
  end
end

describe ThreadMan do
  let(:thread_count) { 5 }
  let(:car_start_speed) { rand(70) }
  let(:car) { Car.new(car_start_speed) }

  context "single actor object" do
    let(:tm) { ThreadMan.new(car) }

    it "should return response after submitting single actor requests" do
      thread_count.times { tm.submit(:drive, rand(90)) }
      tm.tasks_running?.should == true
      tm.response.size.should == thread_count
      tm.tasks_running?.should == false
      tm.response.first[:start_speed].should == car_start_speed
      expect { tm.terminate! }.to_not raise_error
    end

    it "should throw an exception when getting response without submitting actor requests" do
      expect { tm.response }.to raise_error
    end

    it "should raise an error on response" do
      tm.submit(:drive, 100)
      expect { tm.response }.to raise_error
    end
  end

  context "multiple actor objects" do
    let(:tm) { ThreadMan.new }

    it "should return response after submitting multiple actor requests" do
      tm.submit_actor(car, :drive, rand(80))
      thread_count.times { tm.submit_actor(Car.new(rand(20)), :drive, rand(90)) }
      
      resp = []
      while r = tm.next_response
        resp << r
      end
      resp.size.should == thread_count + 1

      tm.response.first[:start_speed].should == car.start_speed
      tm.response.size.should == thread_count + 1

      expect { tm.terminate! }.to_not raise_error
    end
  end
end
