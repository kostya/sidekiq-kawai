require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/test_class'

describe SkQueue do

  it "queue" do
    SkTest.queue_name.should == :test
  end

  it "queue name A::B::C" do
    A::B::C.queue_name.should == :'a-b-c'
  end

  it "aliases for queues" do
    SkTest.queue_name.should == :test
    SkTest.new.queue_name.should == :test
  end

  it "set queue_name" do
    SkTest.set_queue_name :haha
    SkTest.queue_name.should == :haha
    SkTest.new.queue_name.should == :haha
  end

  it "set queue name inside class" do
    class Rq2 < SkTest
      set_queue_name :jopa
    end

    Rq2.queue_name.should == :jopa
  end

  it "should enqueue defined event" do
    SkTest.should_receive(:client_push).with('class' => SkTest, 'args' => [:bla, 1, 'a', []])
    SkTest.bla(1, 'a', [])
  end

  it "insert empty event" do
    SkTest.should_receive(:client_push).with('class' => SkTest, 'args' => [:bla])
    SkTest.bla
  end

 it "should enqueue undefined event" do
   SkTest.should_receive(:client_push).with('class' => SkTest, 'args' => [:bl, 1])
   SkTest.bl(1)
 end

  it "should enqueue undefined event" do
    SkTest.should_receive(:client_push).with('class' => SkTest, 'args' => [:bl2, {}])
    SkTest.bl2({})
  end

  it "should insert event with custom method" do
    SkTest.should_receive(:client_push).with('class' => SkTest, 'args' => [:super, 1,2,3])
    SkTest.add_event(:super, 1, 2, 3)
  end

  it "should insert event with custom method" do
    SkTest.should_receive(:client_push).with('class' => SkTest, 'args' => [:super, [1,2,3]])
    SkTest.add_event(:super, [1, 2, 3])
  end

  it "should insert event with custom method enqueue" do
    SkTest.should_receive(:client_push).with('class' => SkTest, 'args' => [:super, 1,2,3])
    SkTest.enqueue(:super, 1, 2, 3)
  end

  it "enqueue in" do
    SkTest.should_receive(:perform_in).with(10, :super, 1, 2, 3)
    SkTest.enqueue_in(10, :super, 1, 2, 3)
  end

  it "add event in" do
    SkTest.should_receive(:perform_in).with(10, :super, 1, 2, 3)
    SkTest.add_event_in(10, :super, 1, 2, 3)
  end

  describe "consume" do
    before :each do
      @bla = SkTest.new
    end

    it "should call our event" do
      @bla.should_receive(:bla).with(1, 'a', [])
      @bla.perform(:bla, [1, 'a', []])
    end

    it "should call our another event" do
      @bla.should_receive(:bl).with(1)
      @bla.perform('bl', [1])
    end

    it "should call our another event" do
      @bla.should_receive(:bl2).with({})
      @bla.perform('bl2', [{}])
    end

    it "should call our another event" do
      @bla.should_receive(:bl2).with([1,2,3])
      @bla.perform('bl2', [[1,2,3]])
    end

    it "raised when method undefined" do
      lambda do
        SkTest.perform('blasdfds', [1])
      end.should raise_error
    end
  end

  it "should proxy consumer" do
    SkTest.proxy(:ptest)
    SkTest.ptest(111, 'abc').should == 10
    $a.should == 111
    $b.should == 'abc'
  end

end
