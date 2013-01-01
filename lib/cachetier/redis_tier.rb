require 'cachetier/tier'

module Cachetier
	class RedisTier < Tier
	  
	  register_tier_class :redis, RedisTier

	  def initialize(options)
	  	super(options)
	  	@redis = options[redis]
	  	raise "Option :redis is required" if !@redis
	  end

	  def get_val_and_expiration_time(key)
	  	val = @redis.get(key)
	  	expiration_time = Time.now + @redis.ttl(key) if val
	  	val, expiration_time
	  end

	  def reset(key)
	  	@redis.del(key)
	  end

	  def size
	  	0
	  end

	  def expired?(key)
	  	return @redis.get(key).nil?
	  end

    def sweepable?
    	false
    end

	protected

	  def set(key, value, ttl)
	  	@redis.set(key, value)
	  	@redis.expire(key, ttl)
	  	value
	  end

	end
end