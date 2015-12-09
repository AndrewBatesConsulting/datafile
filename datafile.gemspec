# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datafile/version'

Gem::Specification.new do |spec|
  spec.name          = "datafile"
  spec.version       = Datafile::VERSION
  spec.authors       = ["Andrew Bates"]
  spec.email         = ["abates@omeganetserv.com"]

  spec.summary       = %q{no summary}
  spec.description   = %q{no description}
  spec.homepage      = "https://github.com/AndrewBatesConsulting/datafile"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_dependency "sqlite3", "~>1.3.10"
end
