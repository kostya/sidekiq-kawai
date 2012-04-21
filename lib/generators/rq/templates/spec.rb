require File.dirname(__FILE__) + '/../../spec_helper'

describe Rq<%= class_name %> do
  before :each do
    @rq = Rq<%= class_name %>.instance
  end
  
  it "should not raise" do
    @rq.some_event(1)
  end
    
end
