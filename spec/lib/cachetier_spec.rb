require 'spec_helper'
require 'cachetier'

class DummyTier < Cachetier::Tier	
	def set(key, value, ttl)
  end

  def reset(key)
  end
end


class AlwaysExpiredDummyTier < DummyTier
	register_tier_class :always_expired, AlwaysExpiredDummyTier

  def get_val_and_expiration_time(key)
  	return :dummy_cached_value_that_should_never_be_returned, Time.now - 1  # always ewxpired
  end
end

class AlwaysFreshDummyTier < DummyTier
	register_tier_class :always_fresh, AlwaysFreshDummyTier

  def get_val_and_expiration_time(key)
  	return :dummy_cached_value, Time.now + 10  # never expires
  end
end

class SingleValueDummyTier < DummyTier
	register_tier_class :single_value, SingleValueDummyTier

  def initialize(options)
  	super
  	@value = options[:value]
  	@expires_at = Time.now + options[:ttl]
  end

	def get_val_and_expiration_time(key)
  	return @value, @expires_at # never expires
  end

	def set(key, value, ttl)
		@value = [:single_value_tier, value]
		@expires_at = Time.now + ttl
  end

  def reset(key)
  end

  def has_key?(key)
  	true
  end
end


describe Cachetier::Cache do

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

  it "should create a cachetier for class and always return the cached value" do

  	class DummyClass1
  		include Cachetier

  		cachetier :get_cached_val, { always_fresh: nil } do |key| 
  			:dummy_uncached_value 
  		end
  	end

  	DummyClass1.new.get_cached_val(:dummy_key).should == :dummy_cached_value
  end

  it "should create a cachetier for class and never return the cached value" do

  	class DummyClass2
  		include Cachetier

  		cachetier :get_cached_val, { always_expired: nil } do |key| 
  			:dummy_uncached_value 
  		end
  	end

  	DummyClass2.new.get_cached_val(:dummy_key).should == :dummy_uncached_value
  end

  it "should fallback from one tier to the next" do

  	class DummyClass3
  		include Cachetier

  		cachetier :get_cached_val, { always_expired: nil, always_fresh: nil } do |key| 
  			:dummy_uncached_value 
  		end
		end

		# the first tier is always expired, the second is always fresh. 
		# the request should try the first tier, fail, and get from the fresh tier

  	DummyClass3.new.get_cached_val(:dummy_key).should == :dummy_cached_value
  end

  it "should update expired tiers" do

  	class DummyClass4
  		  include Cachetier

  		  cachetier :get_cached_val, { single_value: { value: :initial_value, ttl: 0.1 } } do |key|
  		  	:set_value
  		  end

  	end

  	dummy = DummyClass4.new
  	dummy.get_cached_val(:whatever).should == :initial_value
  	sleep 0.2
  	dummy.get_cached_val(:whatever).should == :set_value   # returned by getter proc
  	dummy.get_cached_val(:whatever).should == [:single_value_tier, :set_value] # returned by tier
  end


end

