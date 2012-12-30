# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cachetier/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yuval Larom"]
  gem.email         = ["yuval@ftbpro.com"]
  gem.description   = %q{Multi-tiered cache}
  gem.summary       = %q{Cache your data on multiple tiers: Redis, Memcached, Mongo, locally, etc}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cachetier"
  gem.require_paths = ["lib"]
  gem.version       = Cachetier::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
