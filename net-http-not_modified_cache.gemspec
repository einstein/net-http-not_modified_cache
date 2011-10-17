# -*- encoding: utf-8 -*-

require 'date'

Gem::Specification.new do |s|
  s.name     = 'net-http-not_modified_cache'
  s.version  = '0.0.0'
  s.date     = Date.today
  s.platform = Gem::Platform::RUBY

  s.summary     = 'Caches responses for requests that respond with "304 - Not Modified"'
  s.description = 'Caches responses for requests that respond with "304 - Not Modified" and adds "if-modified-since" or "if-none-match" headers to future requests'

  s.author   = 'Sean Huber'
  s.email    = 'shuber@einsteinindustries.com'
  s.homepage = 'http://github.com/einstein/net-http-not_modified_cache'

  s.require_paths = ['lib']

  s.files      = Dir['lib/**/*'] + %w(MIT-LICENSE README.rdoc)
  s.test_files = Dir['spec/**/*']

  s.add_dependency('activesupport')
  s.add_dependency('i18n')
  s.add_dependency('rack')
end