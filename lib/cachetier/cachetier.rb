require 'cachetier/cache'

module Cachetier

  def self.config
    @@config ||= {}
  end

  def self.config=(val)
    @@config = val
  end
  
  def self.included(base)
    p ["cachetier included"]
    base.send(:extend, ClassMethods)
  end

  module ClassMethods

    def create_class_method(name, &block)
      self.class.instance_eval do
        define_method(name, &block)
      end
    end

    def alias_class_method(new_name, original_name)
      class_eval %Q{
        class << self
          alias_method :#{new_name}, :#{original_name}
        end
      }
    end

    def cachetier(method_name, options = nil, &block)

      # given a block, create a new class method called method_name
      # if not given a block, a method already exists. create a method called X_with_cachetier
      cached_method_name = block ? method_name : "#{method_name}_with_cachetier"
      
      # create a class method that uses cachetier
      create_class_method cached_method_name do |key|
        @@cachetiers[method_name][key]
      end

      # no block given - need to rename the existing method
      if !block
        
        # the original method will be called via X_without_cachetier
        uncached_method_name = "#{method_name}_without_cachetier"       
        alias_class_method uncached_method_name, method_name

        # calling the original method name will call X_with_cachetier
        alias_class_method method_name, cached_method_name

        # create a block for cachetier that calls the uncached version
        block = proc { |key| self.send(uncached_method_name, key) } 
      end
      
      options = Cachetier::config.merge(options || {})
    	cache = Cachetier::Cache.new(options, &block)
    	(@@cachetiers ||= {})[method_name] = cache
    end

  end


end
