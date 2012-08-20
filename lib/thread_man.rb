require 'thread_man/version'

class ThreadMan
  class << self
    attr_accessor :logger
  end

  def initialize(actor = nil)
    raise 'Not a valid actor object' if actor && !actor.is_a?(Celluloid)

    @init_actor = actor
    @futures = []
    @actors = []
    @response = []
    @next_response_ctr = 0
  end

  def submit(method, *params)
    raise 'Not initialized with a valid actor object' if !@init_actor

    @futures << @init_actor.future(method.to_sym, *params)
    @actors << @init_actor
  end

  def submit_actor(actor, method, *params)
    raise 'Not a valid actor object' if !actor || !actor.is_a?(Celluloid)

    @futures << actor.future(method.to_sym, *params)
    @actors << actor
  end

  def response
    if @futures.size <= 0
      raise 'No actors/requests submitted, cannot process response'
    elsif @response.size == @futures.size
      @response
    else
      (@next_response_ctr..(@futures.size - 1)).each do |index|
        @response << process_request(index)
        @next_response_ctr += 1
      end

      @response
    end
  end

  def next_response
    if @futures.size <= 0
      raise 'No actors/requests submitted, cannot process response'
    elsif @next_response_ctr >= @futures.size
      nil
    else
      value = process_request(@next_response_ctr)
      @response << value
      @next_response_ctr += 1
      value
    end
  end

  def terminate!
    actor_arr = @actors.uniq

    if actor_arr.size > 0
      actor_arr.each do |actor|
        begin
          actor.terminate if actor.alive?
        rescue => e
          log "Terminating actor #{actor.inspect}: #{e.message}"
        end
      end

      @actors.clear
      @futures.clear
      @next_response_ctr = 0
    end
  end

  def tasks_running?
    @actors.uniq.each do |actor|
      actor.tasks.each { |task| return true if task.running? }
    end

    false
  end

  def each_response
    while resp = next_response
      yield resp
    end
  end

  def any_nil_response?
    response.include? nil
  end

  protected

  def process_request(index)
    if @actors[index].alive?
      @futures[index].value
    else
      raise "Actor is dead possibly due to some earlier exception, cannot process response: #{@actors[index].inspect}"
    end
  end

  def log(text)
    if ThreadMan.logger && ThreadMan.logger.respond_to?(:info)
      ThreadMan.logger.info("[ThreadMan] #{text}")
    elsif defined? Rails
      Rails.logger.info("[ThreadMan] #{text}")
    else
      $stdout.print("[ThreadMan] #{text}") and $stdout.flush
    end
  end
end
