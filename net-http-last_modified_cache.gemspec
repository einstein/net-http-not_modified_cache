# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'net/http/last_modified_cache/version'
require 'date'

Gem::Specification.new do |s|
  s.name     = 'net-http-last_modified_cache'
  s.version  = Net::HTTP::LastModifiedCache::Version
  s.date     = Date.today
  s.platform = Gem::Platform::RUBY

  s.summary     = 'Summary'
  s.description = 'Description'

  s.author   = 'Sean Huber'
  s.email    = 'shuber@einsteinindustries.com'
  s.homepage = 'http://github.com/einstein/net-http-last_modified_cache'

  s.require_paths = ['lib']

  s.files      = Dir['lib/**/*'] + %w(MIT-LICENSE README.rdoc)
  s.test_files = Dir['spec/**/*']

  s.add_dependency('activesupport')
  s.add_dependency('i18n')
  s.add_dependency('rack')
end