require 'cachetier/tier'

module Cachetier

  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods

    def cachetier(method_name, options, &block)
    	cache = Cachetier::Cache.new(options, &block)
      @@cachetiers ||= {}
    	@@cachetiers[method_name] = cache

      self.define_method(method_name) do |key|
      	@@cachetiers[method_name][key]
      end
    end

  end


end
