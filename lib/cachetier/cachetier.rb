require 'cachetier/tier'

module Cachetier

  class NilValue
  	def self.value
  	  @@value ||= NilValue.new
  	end
  end
	
	class Base

    attr_reader :tiers, :getter_block

		def initialize(*tiers, &getter_block)
			@tiers = tiers
			@getter_block = getter_block
			raise "Tiers cannot be nil" if !tiers
			raise "Tiers cannot be empty" if tiers.empty?
		end

		def [](key)
			prev_tiers = []
			tiers.each do |tier|
				value = tier[key]
				if value 
					prev_tiers.each do |prev_tier|
						prev_tier[key] = value
					end
					return nil if value == NilValue.value
					return value
				end
			end
			self[key] = getter_block.call if getter_block
		end

		def []=(key, value)
			tiers.each do |tier|
				tier[key] = value
			end
			return value
		end

  end

end