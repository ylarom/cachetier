require 'cachetier/tier'

module Cachetier

  class NilValue
  	def self.value
  	  @@value ||= NilValue.new
  	end
  end
	

end