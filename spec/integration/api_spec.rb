describe Sinatra::API::Helpers do
  include_examples 'integration specs'

  it 'should catch and reject malformed JSON' do
    app.post '/' do
      api_required!({
        id: nil
      })
    end

    post '/', 'x]'
    last_response.status.should == 400
    last_response.body.should match(/malformed json/i)
  end
end