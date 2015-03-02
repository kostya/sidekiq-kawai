class SkTestBatch < SkQueue
  attr_accessor :batches

  def bla(x, y)
    xx, val = batched_by(x, 5) { y }
    process_batch(xx, val) if xx
  end

  def process_batch(xx, val)
    @batches ||= []
    @batches << [xx, val]
  end
end
