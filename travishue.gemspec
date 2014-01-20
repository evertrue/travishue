# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'travishue/version'

Gem::Specification.new do |spec|
  spec.name          = 'travishue'
  spec.version       = Travishue::VERSION
  spec.license     = 'MIT'
  spec.authors     = ['PJ Gray']
  spec.email       = 'pj@evertrue.com'
  spec.summary     = 'Monitor travis builds with Hue'
  spec.description = 'Monitor travis builds with Hue and make your build a disco'
  spec.homepage    = 'https://github.com/evertrue/travishue'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'commander', '~> 4.1.2'
  spec.add_dependency 'terminal-table', '~> 1.4.5'
  spec.add_dependency 'term-ansicolor', '~> 1.0.7'
  spec.add_dependency 'ruby-keychain'
  spec.add_dependency 'travis'
end
