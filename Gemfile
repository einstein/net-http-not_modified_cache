source 'http://rubygems.org'

gemspec

group :development do
  gem 'rspec'
  gem 'guard-rspec'
  if RUBY_PLATFORM =~ /darwin/i # osx
    gem 'growl'
    gem 'rb-fsevent', :require => false
  end
end