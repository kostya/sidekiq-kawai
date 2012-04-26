require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/test_class'

describe RqQueue do

  it "queue" do
    RqTest.instance_variable_get('@queue').should == :test
  end
  
  it "queue name A::B::C" do
    A::B::C.instance_variable_get('@queue').should == :'a-b-c'
  end
  
  it "aliases for queues" do
    RqTest.queue_name.should == :test
    RqTest.instance.queue_name.should == :test
  end

  it "should enqueue defined event" do
    Resque.should_receive(:enqueue).with(RqTest, 'bla', [1, 'a', []])
    RqTest.bla(1, 'a', [])
  end
  
  it "insert empty event" do
    Resque.should_receive(:enqueue).with(RqTest, 'bl', [])
    RqTest.bl
  end
  
  it "should enqueue undefined event" do
    Resque.should_receive(:enqueue).with(RqTest, 'bl', [1])
    RqTest.bl(1)
  end
  
  it "should enqueue undefined event" do
    Resque.should_receive(:enqueue).with(RqTest, 'bl2', [{}])
    RqTest.bl2({})
  end              
  
  it "should insert event with custom method" do
    Resque.should_receive(:enqueue).with(RqTest, 'super', [1, 2, 3])
    RqTest.add_event(:super, 1, 2, 3)
  end
  
  it "should insert event with custom method" do
    Resque.should_receive(:enqueue).with(RqTest, 'super', [[1, 2, 3]])
    RqTest.add_event(:super, [1, 2, 3])
  end              
  
  describe "consume" do
    before :each do
      @bla = RqTest.new
      RqTest.stub!(:instance).and_return(@bla)
    end
    
    it "should call our event" do
      @bla.should_receive(:bla).with(1, 'a', [])
      RqTest.perform('bla', [1, 'a', []])
    end
    
    it "should call our another event" do
      @bla.should_receive(:bl).with(1)
      RqTest.perform('bl', [1])
    end
    
    it "should call our another event" do
      @bla.should_receive(:bl2).with({})
      RqTest.perform('bl2', [{}])
    end                        
    
    it "should call our another event" do
      @bla.should_receive(:bl2).with([1,2,3])
      RqTest.perform('bl2', [[1,2,3]])
    end
      
    it "raised when method undefined" do
      lambda do
        RqTest.perform('blasdfds', [1])
      end.should raise_error
    end
  end
  
  it "should proxy consumer" do
    RqTest.proxy(:ptest)
    RqTest.ptest(111, 'abc').should == 10
    $a.should == 111
    $b.should == 'abc'
  end
  
end
