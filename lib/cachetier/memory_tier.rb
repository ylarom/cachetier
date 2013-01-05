require 'cachetier/tier'

module Cachetier
  class MemoryTier < Tier
    
    register_tier_class :mem, MemoryTier

    def initialize(options = nil)
      super
      @cache = {}
    end

    def get_val_and_expiration_time(key)
      val, expiration_time = @cache[key]
    end

    def reset(key)
      @cache.delete(key)
    end

    def size
      @cache.size
    end

    def keys
      return @cache.keys
    end

    def expired?(key)
      val, expiration_time = get_val_and_expiration_time(key)
      return expiration_time < Time.now
    end

  protected

    def set(key, value, ttl)
      @cache[key] = [value, Time.now + ttl.to_f]
    end

  end
end