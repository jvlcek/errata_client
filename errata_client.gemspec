# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'errata_client/version'

Gem::Specification.new do |spec|

  authors_hash = {
    "Alberto Bellotti" => "abellott@redhat.com"
  }

  spec.name          = "errata_client"
  spec.version       = ErrataClient::VERSION
  spec.authors       = authors_hash.keys
  spec.email         = authors_hash.values
  spec.description   = %q{ErrataClient is a client library interface to the RedHat Errata Tool}
  spec.summary       = %q{ErrataClient is a client library interface to the RedHat Errata Tool}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.files        += %w[README.md LICENSE.txt]
  spec.executables   = `git ls-files -- bin/*`.split("\n")
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency('json')
  spec.add_dependency('curb')
  spec.add_dependency('rack')
end
