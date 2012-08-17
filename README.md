Sidekiq Kawai
============

Syntax sugar for Sidekiq consumers. Each consumer is a class, with clean interface, and custom logger.
Usefull when count of different events ~100 and more.

``` ruby
gem 'sidekiq-kawai'
```

    rails generate sk:add bla

And add to config/application.rb

    config.autoload_paths += %W( #{config.root}/app/models/sidekiq )

Consumer
--------
app/workers/sk_bla.rb

``` ruby
class SkBla < SkQueue

  def some_method1(a, b, c)
    logger.info "async called some_method1 with #{[a, b, c].inspect}"
  end

  def some_method2(x)
    logger.info "async called some_method2 with #{x.inspect}"
  end

end
```

Insert event into queue like this:

    SkBla.some_method1(1, 2, 3)

    or

    SkBla.add_event(:some_method2, some_x)


Logger for this consumer: Rails.root/log/workers/bla.log



### Options

``` ruby
class SkBla < RkQueue

  # specify custom logger
  sidekiq_options :logger_path => "#{Rails.root}/log/bla.log"

  # enables benchmark for each event (into logger)
  sidekiq_options :benchmark => true

end
```


### Proxy method to consumer
Usefull in specs

``` ruby
  SkBla.proxy(:some_method1)
```

When code call SkBla.some_method1(a,b,c) this would be convert into SkBla.new.some_method1(a,b,c)



### Insert events with scheduler

``` ruby
SkBla.add_event_in(10.seconds, :some_method1, 1, 2, 3)

SkBla.enqueue_in(10.seconds, :some_method1, 1, 2, 3)

SkBla.some_method2_in(2.minutes.from_now, "call instance method on Worker sheduled async")

SkBla.some_method2_at(2.minutes.from_now, "call instance method on Worker sheduled async")
```
