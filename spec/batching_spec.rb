require File.dirname(__FILE__) + '/spec_helper'

describe "Batching" do
  before :each do
    SkTestBatch.clear_batch
  end

  it "case 1" do
    @test = SkTestBatch.new
    11.times do
      @test.bla(1, 2)
    end
    @test.batches.should == [[[1,1,1,1,1], 2], [[1,1,1,1,1], 2]]
  end

  it "case 2" do
    @test = SkTestBatch.new
    @test.bla(1, 2)
    @test.bla(2, 2)
    @test.bla(3, 3)
    @test.bla(4, 3)
    @test.bla(5, 6)
    @test.batches.should == [[[1,2], 2], [[3, 4], 3]]
  end

  it "case 3" do
    @test = SkTestBatch.new
    @test.bla(1, 1)
    @test.bla(2, 2)
    @test.bla(3, 3)
    @test.bla(4, 4)
    @test.batches.should == [[[1], 1], [[2], 2], [[3], 3]]
  end

end
