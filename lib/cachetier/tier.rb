module Cachetier
  class Tier
    
    attr_reader :ttl, :high_watermark, :low_watermark

    def initialize(ttl, high_watermark = nil, low_watermark = nil)
    	@ttl, @high_watermark, @low_watermark = ttl, high_watermark, low_watermark
    	raise "High watermark must be a positive number" if high_watermark && high_watermark <= 0
    	raise "Low watermark must be a positive number"  if low_watermark  && low_watermark  <= 0
    end

    def [](key)
    	val, expiration_time = get_val_and_expiration_time(key)
    	
    	if expiration_time && Time.now > expiration_time
    		val = nil
    		reset key
    	end

    	return val
    end

    def []=(key, value)
      sweep_if_needed
    	set(key, value, ttl)
    end

  protected

    def sweep_if_needed
    	if high_watermark && low_watermark
  	  	sweep if size >= high_watermark
  	  end
    end

    def sweep
    	do_sweep(false)
    	if size >= high_watermark
    	  do_sweep(true)
    	end
    end

    def do_sweep(force)
  	  curr_size = size
  	  keys.each do |key|
  	  	if force || expired?(key)
  	  		reset(key)
  	  		curr_size -= 1
  	  		break if curr_size <= low_watermark
  	  	end
  	  end
    end

  end

end