require 'spec_helper'
require 'cachetier'

describe Cachetier::Tier do

	it "should validate tier ctor args" do
		expect { Cachetier::Tier.new(ttl: -1) }.to raise_error
		Cachetier::Tier.new(ttl: 10).should_not be_nil
		
		expect { Cachetier::Tier.new(high_watermark: -1) }.to raise_error
		expect { Cachetier::Tier.new(low_watermark: -1) }.to raise_error
		expect { Cachetier::Tier.new(high_watermark: 1, low_watermark: 3) }.to raise_error
		Cachetier::Tier.new(high_watermark: 3, low_watermark: 1).should_not be_nil
	end

	it "should be able to modify tier writability and sweepability" do

    Cachetier::Tier.new.writable?.should be_true
    Cachetier::Tier.new.sweepable?.should be_true

    Cachetier::Tier.new(writable: true, sweepable: false).writable?.should be_true
    Cachetier::Tier.new(writable: true, sweepable: false).sweepable?.should be_false

    Cachetier::Tier.new(writable: false, sweepable: true).writable?.should be_false
    Cachetier::Tier.new(writable: false, sweepable: true).sweepable?.should be_true

  end

  
end