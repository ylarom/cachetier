require 'spec_helper'
require 'cachetier'

describe Cachetier::MemoryTier do

  it "should return nil if nothing there" do
    cache = Cachetier::Base.new(Cachetier::MemoryTier.new(0.2))
    cache[:a].should == nil
  end
  
  it "should use memory tier to save data for 2 sec then expire it" do
    cache = Cachetier::Base.new(Cachetier::MemoryTier.new(0.2))
    cache[:a] = 1
    cache[:a].should == 1
    sleep 0.1
    cache[:a].should == 1
    sleep 0.2
    cache[:a].should == nil
  end

  it "should use getter_block to set value" do
    cache = Cachetier::Base.new(Cachetier::MemoryTier.new(0.2)) { :the_value }
    cache[:a].should == :the_value
  end


end

