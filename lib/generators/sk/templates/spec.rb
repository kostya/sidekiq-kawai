require File.dirname(__FILE__) + '/../../spec_helper'

describe Sk<%= class_name %> do
  before :each do
    @sk = Sk<%= class_name %>.new
  end

  it "should not raise" do
    @sk.some_event(1)
  end

end
