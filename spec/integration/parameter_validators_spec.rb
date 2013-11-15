describe Sinatra::API::ParameterValidator do
  include_examples 'integration specs'

  context 'type validators' do
    context ':string' do
      it 'should accept a string value' do
        app.get '/' do
          api_parameter! :name, required: true, type: :string
          api_parameter :name
        end

        get '/', { name: 'foo' }
        last_response.status.should == 200
        last_response.body.should == 'foo'
      end

      it 'should reject a non-string value' do
        app.post '/' do
          api_parameter! :name, required: true, type: :string
          api_parameter :name
        end

        rc = api_call post '/', { name: 5 }.to_json
        rc.should fail(400, '')
        rc.body[:field_errors][:name].should match(/expected.*string/i)
      end

    end
  end
end