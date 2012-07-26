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
app/models/sidekiq/sk_bla.rb

``` ruby
class SkBla < SqQueue

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

    RqBla.add_event(:some_method2, some_x)


Logger for this consumer: Rails.root/log/sidekiq/bla.log



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


### Insert event with Sidekiq-scheduler

``` ruby
  RqBla.add_event_in(10.seconds, :some_method1, 1, 2, 3)

  RqBla.enqueue_in(10.seconds, :some_method1, 1, 2, 3)

  RqBla.some_method_in(2.minutes.from_now,"call instance method on Worker sheduled async")

  RqBla.some_method_at(2.minutes.from_now,"call instance method on Worker sheduled async")
```
