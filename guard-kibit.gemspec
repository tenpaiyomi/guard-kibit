# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'guard/kibit/version'

Gem::Specification.new do |spec|
  spec.name          = 'guard-kibit'
  spec.version       = GuardKibitVersion.to_s
  spec.authors       = ['Eric Musgrove']
  spec.email         = ['eric.musgrove@hexawise.com']
  spec.summary       = 'Guard plugin for Kibit'
  spec.description   = 'Guard::Kibit automatically checks Clojure code style with Kibit ' \
                       'when files are modified.'
  spec.homepage      = 'https://github.com/tenpaiyomi/guard-kibit'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'guard', '~> 2.0'

  spec.add_development_dependency 'bundler',        '~> 1.3'
  spec.add_development_dependency 'guard-rspec',    '>= 4.2.3', '< 5.0'
  spec.add_development_dependency 'guard-rubocop',  '~> 1.3.0'
  spec.add_development_dependency 'rake',           '~> 12.0'
  spec.add_development_dependency 'rspec',          '~> 3.0'
  spec.add_development_dependency 'rubocop',        '~> 0.20'
  spec.add_development_dependency 'simplecov',      '~> 0.7'
end
