spec_root = File.dirname(__FILE__)
$:.unshift(File.join(spec_root, '..', 'lib'))
$:.unshift(spec_root)

require 'net-http-last_modified_cache'

Dir[File.join(spec_root, 'support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
end