require 'spec/helpers/rack_test_api_response'
require 'spec/helpers/rspec_api_response_matchers'

# Converts a Rack::Test HTTP mock response into an API one.
#
# @see Rack::Test::APIResponse
#
# @example usage
#   rc = api_call get '/api/endpoint'
#   rc.should fail(400, 'some error explanation')
#   rc.should succeed(201)
#   rc.messages.empty?.should be_true
#   rc.status.should == :error
#
# @example using expect {}
#   expect { api_call get '/foobar' }.to succeed(200)
def api_call(rack_response)
  Rack::Test::APIResponse.new(rack_response)
end

# Does the same thing as #api_call but wraps it into a block.
#
# @example usage
#   api { get '/api/endpoint' }.should fail(403, 'not authorized')
#
# @see #api_call
def api(&block)
  api_call(block.yield)
end

RSpec.configure do |config|
  config.include RSpec::APIResponseMatchers
end
