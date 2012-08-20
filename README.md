## ThreadMan

ThreadMan uses `Celluloid` to abstract out concurrent requests pattern.

### Installation

Add this line to your application's Gemfile:

    gem 'thread_man'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install thread_man

### Usage

Sample celluloid object:

```ruby
class Car
  include Celluloid

  def initialize(start_speed = 10)
    @start_speed = start_speed
    @name = "Audi #{rand(10)}"
  end

  def drive(speed = 80)
    sleep [1, 1.5, 2].sample
    { name: @name, current_speed: speed, start_speed: @start_speed }
  end

  def start_speed
    @start_speed
  end
end
```

ThreadMan usage inside a rails controller to make async requests:

```ruby
class HomeController < ApplicationController
  def index
    car = Car.new(70)
    tm = ThreadMan.new(car)

    # Async invocation of `drive` method.
    4.times { tm.submit(:drive, 76) }

    # Get response to first submitted request. Blocking request.
    tm.next_response

    # Get all responses for the submitted requests. Blocking request.
    # Array of responses. Order is the same as the "submit" order.
    response = tm.response

    # NOTE: This is required for GC. Ideally you will call this inside `ensure`
    tm.terminate!

    render json: response
  end
end
```

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
