class SkTest < SkQueue

  sidekiq_options :logger_path => "test.log"
  sidekiq_options :benchmark => true

  def bla(a, b, c)
    @hah = [a, b, c]
    logger.info "bla #{@hah.inspect}"
  end

  def ptest(a, b)
    $a = a
    $b = b
    10
  end

end

module A
  module B
    class C < SkQueue
    end
  end
end
