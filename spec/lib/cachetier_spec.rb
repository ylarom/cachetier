require 'spec_helper'
require 'cachetier'

describe Cachetier::MemoryTier do

  it "should return nil if nothing there" do
    cache = Cachetier::Cache.new(mem: { ttl: 0.2 })
    cache[:a].should == nil
  end
  
  it "should use memory tier to save data for 2 sec then expire it" do
    cache = Cachetier::Cache.new(mem: { ttl: 0.2 })
    cache[:a] = 1
    cache[:a].should == 1
    sleep 0.1
    cache[:a].should == 1
    sleep 0.2
    cache[:a].should == nil
  end

  it "should use getter_block to set value" do
    cache = Cachetier::Cache.new(mem: { ttl: 0.2 }) { :the_value }
    cache[:a].should == :the_value
  end

  it "should create a cachetier for class and return an always true cached value" do

  	class AlwaysTrueDummyTier < Cachetier::Tier
  		register_tier_class :true_dummy, AlwaysTrueDummyTier

  	  def get_val_and_expiration_time(key)
  	  	return :dummy_cached_value
		  end

		  def reset(key)
		  end

		  def set(key, value, ttl)
		  end
  	end

  	class DummyClass1
  		include Cachetier

  		cachetier :get_cached_val, { true_dummy: {} } do |key| 
  			:dummy_real_value 
  		end
  	end

  	DummyClass1.new.get_cached_val(:dummy_key).should == :dummy_cached_value
  end

  it "should create a cachetier for class and never return an always false cached value" do

  	class AlwaysFalseDummyTier < Cachetier::Tier
  		register_tier_class :false_dummy, AlwaysFalseDummyTier

  	  def get_val_and_expiration_time(key)
  	  	return :dummy_cached_value, Time.now - 1
		  end

		  def reset(key)
		  end

		  def set(key, value, ttl)
		  end
  	end

  	class DummyClass2
  		include Cachetier

  		cachetier :get_cached_val, { false_dummy: nil } do |key| 
  			:dummy_real_value 
  		end
  	end

  	DummyClass2.new.get_cached_val(:dummy_key).should == :dummy_real_value
  end

end

