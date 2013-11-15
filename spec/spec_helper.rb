$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

ENV['RACK_ENV'] = 'test'

require 'lib/sinatra/api'
require 'rspec'
require 'rack/test'

class SinatraAPITestApp < Sinatra::Base
  register Sinatra::API
end

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  Thread.abort_on_exception = true

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

Dir["./spec/{helpers,support}/**/*.rb"].sort.each { |f| require f }