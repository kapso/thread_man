# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thread_man/version'

Gem::Specification.new do |gem|
  gem.name          = 'thread_man'
  gem.version       = ThreadMans::VERSION
  gem.authors       = ['Kapil']
  gem.email         = ['kapil.israni@gmail.com']
  gem.description   = 'ThreadMan uses Celluloid to abstract out concurrent requests pattern.'
  gem.summary       = gem.description
  gem.homepage      = 'http://github.com/kapso/thread_man'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency             'celluloid', '~> 0.11.1'
  gem.add_development_dependency 'rspec'
end
