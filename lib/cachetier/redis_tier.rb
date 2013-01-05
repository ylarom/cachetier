require 'cachetier/tier'

module Cachetier
	class RedisTier < Tier
	  
	  register_tier_class :redis, RedisTier

	  def initialize(options)
	  	super
	  	@redis = options[:redis]
	  	raise "Option :redis is required" if !@redis
	  end

	  def get_val_and_expiration_time(key)
	  	val = @redis.get(key)
	  	expiration_time = Time.now + @redis.ttl(key) if val
	  	return [val, expiration_time]
	  end

	  def reset(key)
	  	@redis.del(key)
	  end
	  
	protected

		def size
	  	0
	  end
	  
		def sweepable?
    	false
    end

	  def set(key, value, ttl)
	  	@redis.multi do
	  		@redis.set(key, value)
	  		@redis.expire(key, ttl)
	  	end
	  	value
	  end

	end
end