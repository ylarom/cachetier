module Cachetier
  class Tier

    def self.register_tier_class(name, klass)
      @@tier_classes ||= {}
      @@tier_classes[name] = klass
    end

    def self.get_tier_class(name)
      return @@tier_classes[name]
    end
    
    attr_reader :ttl, :high_watermark, :low_watermark

    DEFAULTS = {
      ttl: 0,
      high_watermark: nil,
      low_watermark: nil
    }

    def initialize(options = nil)
      @options = DEFAULTS.dup.merge((options || {}).dup)
      raise "TTL must be a positive number" if ttl && ttl < 0
    	raise "High watermark must be a positive number" if high_watermark && high_watermark <= 0
    	raise "Low watermark must be a positive number"  if low_watermark  && low_watermark  <= 0
      raise "High watermark must be larger than lower watermark" if high_watermark && low_watermark && high_watermark <= low_watermark
    end

    def ttl
      @options[:ttl]
    end

    def high_watermark
      @options[:high_watermark]
    end

    def low_watermark
      @options[:low_watermark]
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
      raise "Read-only tier" if !writable?
      sweep_if_needed if sweepable?
    	set(key, value, ttl)
    end

    def writable?
      return @options[:writable] if @options.has_key?(:writable)
      true
    end

    def sweepable?
      return @options[:sweepable] if @options.has_key?(:sweepable)
      true
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
      raise "Read-only tier" if !writable?
      raise "Un-sweeable tier" if !sweepable?
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