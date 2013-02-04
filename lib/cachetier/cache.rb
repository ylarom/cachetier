require 'cachetier/tier'
require 'cachetier/nil_value'

module Cachetier
	
	class Cache

    attr_reader :tiers, :getter_block

		def initialize(tiers, &getter_block)
			raise "Tiers cannot be nil" if !tiers
			raise "Tiers cannot be empty" if tiers.empty?

			@tiers = tiers.map do |name, options|
				tier_class = Tier.get_tier_class(name)
				tier = tier_class.new(options)
			end

			@getter_block = getter_block
		end

		def [](key)
			prev_tiers = []

			# some tiers override the key. save original clone of it
		  orig_key = begin 
		  	key.clone
		  rescue
		    key
		  end

			tiers.each do |tier|				
				value = tier[key]
				key = orig_key

				if value
					update_tiers(key, value, prev_tiers)
					return nil if value == NilValue.value
					return value
				end
				prev_tiers << tier
			end

			# block might change key
			self[orig_key] = getter_block.call(key) if getter_block
		end

		def []=(key, value)

			value = NilValue if value.nil?
			tiers.each do |tier|
				tier[key] = value if tier.writable?
			end
			return value
		end

	protected

	  def update_tiers(key, value, tiers)
	  	tiers.each do |tier|
				tier[key] = value if tier.writable?
			end
	  end

  end

end