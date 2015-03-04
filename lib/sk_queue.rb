# -*- encoding : utf-8 -*-
require 'active_support'
require 'active_support/inflector' unless ''.respond_to?(:underscore)
require 'sidekiq'

class SkQueue
  include Sidekiq::Worker

  sidekiq_options :retry => true, :benchmark => false, :alerts => true

  def self.extract_queue_name
    name.gsub(/^Sk/, '').underscore.gsub('/', '-').to_sym rescue :default
  end

  def self.inherited(subclass)
    subclass.class_eval do
      sidekiq_options :queue => extract_queue_name
      sidekiq_options :logger_path => File.expand_path("log/workers/#{queue_name}.log")
    end
  end

  def perform(method_name, args)
    start_time = benchmark ? Time.now : nil

    self.send(method_name, *args)

    logger.info "done #{method_name}, #{"%.6f" % (Time.now - start_time)} s" if benchmark

  rescue => ex
    if alerts
      logger.error "!Failed event: #{method_name} => #{ex.message}, #{args.inspect}"
      self.class.notify_about_error(ex)
    end
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

  def self.alerts
    get_sidekiq_options['alerts']
  end

  def self.alerts=(val)
    sidekiq_options :alerts => val
  end

  def alerts
    self.class.alerts
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
      add_event_in(args.shift, $1.to_s.to_sym, *args)
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
    allow(self).to receive(method_name) do |*data|
      x = Sidekiq.load_json(Sidekiq.dump_json(data))
      self.new.send(method_name, *x)
    end
  end

  def self.notify_about_error(exception)
    # stub
  end


  # ======== Batch processing ==========
  @@prev_value = nil
  @@queue = []
  @@mutex = Mutex.new

  def batched_by(elem, max_elems, &block)
    new_value = block ? block.call : nil
    if @@queue.length >= max_elems || (@@prev_value && @@prev_value != new_value)
      return_value = nil
      return_queue = nil
      @@mutex.synchronize do
        return_value = @@prev_value
        return_queue = @@queue.dup
        @@prev_value = new_value
        @@queue = [elem]
      end
      block ? [return_queue, return_value] : return_queue
    else
      @@mutex.synchronize do
        @@queue << elem
        @@prev_value = new_value
      end
      nil
    end
  end

  def self.clear_batch
    @@mutex.synchronize do
      @@queue = []
      @@prev_value = nil
    end
  end
  # =====================================

end
