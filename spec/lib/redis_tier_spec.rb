require 'spec_helper'
require 'cachetier'
require 'cachetier/redis_tier'

describe Cachetier::RedisTier do

	it "should require redis param" do
		expect { Cachetier::RedisTier.new({}) }.to raise_error
	end

	it "should try fetching value from redis, and check redis ttl" do
  	redis = double("redis")
  	redis.stub(get: :redis_cached_value)
  	redis.stub(ttl: 1)

		cache = Cachetier::RedisTier.new({redis: redis})

		redis.should_receive(:ttl).with(:key)
		cache[:key].should == :redis_cached_value
	end

	it "should try fetching value from redis, and check redis ttl" do
  	redis = double("redis")
  	redis.stub(multi: 1)

		cache = Cachetier::RedisTier.new({redis: redis})

		redis.should_receive(:multi)
		cache[:key] = 1

	end
end

