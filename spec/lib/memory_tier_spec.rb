require 'spec_helper'
require 'cachetier'

describe Cachetier::MemoryTier do
  it "should save data for 2 sec then expire it" do
    cache = Cachetier::MemoryTier.new(0.2)
    cache[:a] = 1
    cache[:a].should == 1
    sleep 0.1
    cache[:a].should == 1
    sleep 0.2
    cache[:a].should == nil

  end
end
