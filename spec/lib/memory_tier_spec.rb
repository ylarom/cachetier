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

  it "should sweep oldest keys when reaching high_watermark until only low_watermark items remain" do
    cache = Cachetier::MemoryTier.new(0.2, 20, 10)

    20.times do |i|
    	cache[i] = i
    	cache.size.should == i + 1
    end

    # now that we have 20 items in the cache, 
    # adding a new item should triggr a sweep old keys until size is 10, 
    # and then the new item is added, bringing size to 11

    cache[99] = 99
    cache.size.should == 11
    
    # make sure oldest keys are gone

    10.times do |i|
    	cache[i].should == nil
    end

    # make sure newest keys are there

    (11 .. 19).each do |i|
    	cache[i].should == i
    end

    cache[99].should == 99
  end

  
end
