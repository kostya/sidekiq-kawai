class RqTest < RqQueue

  self.logger_path = "test.log"
  self.benchmark = true

  def bla(a, b, c)
    @hah = [a, b, c]
    logger.info "bla #{@hah.inspect}"
  end
  
  def ptest(a)
    $a = a
    10
  end

end
