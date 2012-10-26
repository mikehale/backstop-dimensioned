require 'backstop-dimensioned'
require 'webmock/rspec'
require 'timecop'

APP_ROOT = File.expand_path(File.dirname(__FILE__) + "/..")

Scrolls::Log.stream = File.new(File::NULL, 'w')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
