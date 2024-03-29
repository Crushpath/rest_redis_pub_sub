# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rest_redis_pub_sub/version'

Gem::Specification.new do |spec|
  spec.name          = "rest_redis_pub_sub"
  spec.version       = RestRedisPubSub::VERSION
  spec.authors       = ["Crushpath"]
  spec.email         = ["support@crushpath.com"]
  spec.summary   = %q{RestRedisPubSub is a small library for publishing, subscribing and handling messages via Redis pub/sub.}
  spec.description   = spec.summary
  spec.homepage      = "http://crushpath.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
