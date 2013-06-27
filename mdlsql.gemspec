# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mdlsql/version'

Gem::Specification.new do |spec|
  spec.name          = "mdlsql"
  spec.version       = MdlSql::VERSION
  spec.authors       = ["Sikian"]
  spec.email         = ["sikian@gmail.com"]
  spec.homepage    = "https://github.com/Sikian/mdlsql"
  spec.summary     = %q{A modular query builder to enable a high database compatibility, usage easiness and dynamic construction.}
  spec.description = %q{Modular Sql is a modular query builder that enables a high database compatibility, usage easiness and dynamic construction. It is intended to allow any kind of query in any database, but will, at the moment, only handle relatively simple ones to most common databases.}

  spec.license       = "GPL-3.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mysql2"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
