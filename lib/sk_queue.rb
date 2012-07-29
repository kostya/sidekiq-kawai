# -*- encoding : utf-8 -*-
require 'active_support'
require 'active_support/inflector' unless ''.respond_to?(:underscore)
require 'sidekiq'

class SkQueue
  include Sidekiq::Worker

  sidekiq_options :retry => true, :benchmark => false

  def self.extract_queue_name
    name.gsub(/^Sk/, '').underscore.gsub('/', '-').to_sym rescue :default
  end

  def self.inherited(subclass)
    subclass.class_eval do
      sidekiq_options :queue => extract_queue_name
      sidekiq_options :logger_path => File.expand_path("log/sidekiq/#{queue_name}.log")
    end
  end

  def perform(method_name, args)
    start_time = benchmark ? Time.now : nil
    
    self.send(method_name, *args)
    
    logger.info "done #{method_name}, #{"%.6f" % (Time.now - start_time)} s" if benchmark
    
  rescue => ex
    logger.error "!Failed event: #{method_name} => #{ex.message}, #{args.inspect}"
    self.class.notify_about_error(ex)    
    raise ex
  end

  def self.benchmark
    get_sidekiq_options['benchmark']
  end

  def self.benchmark=(val)
    sidekiq_options :benchmark => val
  end

  def benchmark
    self.class.benchmark
  end

  def self.queue_name
    get_sidekiq_options['queue']
  end

  def queue_name
    self.class.queue_name
  end

  def self.set_queue_name(val)
    sidekiq_options :queue => val
  end


  def self.logger_path
    get_sidekiq_options['logger_path']
  end

  def logger_path
    self.class.logger_path
  end




  def self.add_event(method_name, *args)
    client_push('class' => self, 'args' => [method_name, args])
  end

  def self.enqueue(method_name, *args)
    add_event method_name, *args
  end

  def self.add_event_in(interval, method_name, *args)
    perform_in(interval, method_name, args)
  end

  def self.enqueue_in(interval, method_name, *args)
    add_event_in(interval, method_name, *args)
  end
  
  # Worker.some_method("call new method on Worker async")
  # Worker.some_method_in(2.minutes.from_now,"call new method on Worker sheduled async")
  # Worker.some_method_at(2.minutes.from_now,"call new method on Worker sheduled async")
  def self.method_missing(method_name, *args)    
    if method_name.to_s[/\A(\w*)_((at)|(in))\z/]
      add_event_in(args.shift, $1, *args)
    else
      add_event(method_name, *args)
    end
  end




  def logger
    @logger ||= Logger.new(logger_path).tap do |logger|
      logger.formatter = lambda { |s, d, p, m| "#{d.strftime("%d.%m.%Y %H:%M:%S")} #{m}\n" }
    end
  end

  def self.proxy(method_name)
    self.should_receive(method_name) do |*data|
      x = Sidekiq.load_json(Sidekiq.dump_json(data))
      self.new.send(method_name, *x)
    end.any_number_of_times
  end
  
  def self.notify_about_error(exception)
    # stub
  end

end
