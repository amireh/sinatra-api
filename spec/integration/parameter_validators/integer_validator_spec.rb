describe Sinatra::API::IntegerValidator do
  include_examples 'integration specs'

  it 'should accept a numeric value' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :integer
      api_params.to_json
    end

    rc = api_call post '/', { rate: 5 }.to_json
    rc.should succeed
    rc.body[:rate].should == 5
  end

  it 'should reject a non-numeric value' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :integer
      api_params.to_json
    end

    rc = api_call post '/', { rate: 'asdf' }.to_json
    rc.should fail(400, 'not a valid integer')

    rc = api_call post '/', { rate: '5.73' }.to_json
    rc.should fail(400, 'not a valid integer')

    rc = api_call post '/', { rate: [] }.to_json
    rc.should fail(400, 'not a valid integer')

    rc = api_call post '/', { rate: {} }.to_json
    rc.should fail(400, 'not a valid integer')
  end

  it 'should round a float' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :integer
      api_params.to_json
    end

    rc = api_call post '/', { rate: 5.75 }.to_json
    rc.should succeed
    rc.body[:rate].should == 5
  end

  it 'should coerce an integer' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :integer
      api_params.to_json
    end

    rc = api_call post '/', { rate: "15" }.to_json
    rc.should succeed
    rc.body[:rate].should == 15
  end

  it 'should not coerce an integer' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :integer, coerce: false
      api_params.to_json
    end

    rc = api_call post '/', { rate: "15" }.to_json
    rc.should succeed
    rc.body[:rate].should == "15"
  end
end