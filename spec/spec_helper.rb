$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

ENV['RACK_ENV'] = 'test'

require 'lib/sinatra/api'
require 'rspec'
require 'rack/test'

class SinatraAPITestApp < Sinatra::Base
  register Sinatra::API
  Sinatra::API.configure({
    verbose: false,
    with_errors: true
  })

end

RSpec.configure do |config|
  Thread.abort_on_exception = true

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true
  config.order = 'random'

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

Dir["./spec/{helpers,support}/**/*.rb"].sort.each { |f| require f }