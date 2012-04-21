Resque Kawai
============

Syntax sugar for Resque consumers. Each consumer is a class, with clean interface, and custom logger.

``` ruby
gem 'resque-kawai'
```

    rails generate rq:add bla

And add to config/application.rb

    config.autoload_paths += %W( #{config.root}/app/models/resque )
    
Consumer
--------
app/models/resque/rq_bla.rb

``` ruby
class RqBla < RqQueue

  def some_method1(a, b, c)
    logger.info "async called some_method1 with #{[a, b, c].inspect}"
  end
  
  def some_method2(x)
    logger.info "async called some_method2 with #{x.inspect}"
  end
  
end
```

Insert event into queue like this:

    RqBla.some_method1(1, 2, 3)
    
    or
    
    RqBla.add_event(:some_method2, some_x)
    

Logger for this consumer: Rails.root/log/resque/bla.log


 
### Options

``` ruby
class RqBla < RqQueue

  # specify custom logger
  self.logger_path = "#{Rails.root}/log/bla.log"
  
  # enables benchmark for each event (into logger)
  self.benchmark = true
  
end
```


### Proxy method to consumer
Usefull in specs

``` ruby
  RqBla.proxy(:some_method1)
```

When code call RqBla.some_method1(a,b,c) this would be convert into RqBla.new.some_method1(a,b,c)
