describe Sinatra::API::ParameterValidator do
  include_examples 'integration specs'

  context 'defining parameters' do
    it 'should define a required parameter using hash style' do
      app.post '/' do
        api_required!({
          id: :integer
        })
        api_params.to_json
      end

      rc = api_call post '/', { id: "15" }.to_json
      rc.should succeed(200)
      rc.body[:id].should == 15
    end

    it 'should work with nested-hashes' do
      pending 'nested parameter groups'

      app.post '/' do
        api_required!({
          project: {
            id: :integer
          }
        })
        api_params.to_json
      end

      rc = api_call post '/', { project: { id: "15" } }.to_json
      rc.should succeed(200)
      puts rc.body.inspect
      rc.body[:project][:id].should == 15
    end

  end
end