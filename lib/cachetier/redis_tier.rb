require 'cachetier/tier'

module Cachetier
	class RedisTier < Tier
	  
	  def initialize(redis, ttl, high_watermark = nil, low_watermark = nil)
	  	super(ttl, high_watermark, low_watermark)
	  	@redis = redis
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

	protected

	  def set(key, value, ttl)
	  	@redis.set(key, value)
	  	@redis.expire(key, ttl)
	  	value
	  end

	end
end