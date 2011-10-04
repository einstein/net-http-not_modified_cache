require 'rubygems'
require 'bundler/setup'

# [TODO] why do specs fail without this?
# [TODO] why doesn't "gem 'timecop', :require => 'timecop/timecop'" work?
require 'timecop/timecop'

spec_root = File.dirname(__FILE__)
$:.unshift(File.join(spec_root, '..', 'lib'))
$:.unshift(spec_root)
require 'net-http-not_modified_cache'

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before { Net::HTTP::NotModifiedCache.enable! }
end