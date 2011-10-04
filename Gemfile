source 'http://rubygems.org'

gemspec

group :development do
  gem 'fakeweb'
  gem 'rake'
  gem 'rspec'
  gem 'guard-rspec'
  gem 'timecop'
  if RUBY_PLATFORM =~ /darwin/i # osx
    gem 'growl'
    gem 'rb-fsevent', :require => false
  end
end