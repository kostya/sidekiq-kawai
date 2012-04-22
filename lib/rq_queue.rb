# -*- encoding : utf-8 -*-
require 'active_support'
require 'active_support/inflector' unless ''.respond_to?(:underscore)
require 'resque'
require 'logger'

class RqQueue
  @queue = :default
  
  attr_accessor :logger
  
  def self.inherited(subclass)
    subclass.instance_variable_set('@queue', subclass.extract_queue_name)
  end
  
  def self.extract_queue_name
    name.gsub(/Rq/, '').underscore.to_sym
  end
  
  def self.add_event(method_name, *args)
    Resque.enqueue(self, method_name.to_s, args)
  end
  
  def self.method_missing(method, *args)
    add_event(method, *args)
  end
  
  def self.logger
    @logger ||= Logger.new(logger_path).tap do |logger|
      logger.formatter = lambda { |s, d, p, m| "#{d.strftime("%d.%m.%Y %H:%M:%S")} #{m}\n" }
    end
  end
  
  def self.instance
    @instance ||= self.new
  end
  
  def self.perform(method_name, args)
    start_time = benchmark ? Time.now : nil
    
    instance.send(method_name, *args)
    
    logger.info "done #{method_name}, #{"%.6f" % (Time.now - start_time)} s" if benchmark
   
  rescue => ex
    logger.error "!Failed event: #{method_name} => #{ex.message}"
    raise ex
  end

  # proxing method for tests  
  def self.proxy(method_name)
    self.should_receive(method_name) do |*data|
      self.instance.send(method_name, *data)
    end.any_number_of_times
  end
  
  class << self
    def logger_path=(_logger_path)
      @logger_path = _logger_path
    end
    
    def logger_path 
      @logger_path ||= begin        
        "#{Rails.root}/log/resque/#{extract_queue_name}.log"
      end
    end
    
    attr_accessor :benchmark
  end
  
  def initialize
    self.logger = self.class.logger
  end
  
end
