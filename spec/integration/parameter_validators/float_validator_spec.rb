describe Sinatra::API::FloatValidator do
  include_examples 'integration specs'

  it 'should accept a float' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :float
      api_params.to_json
    end

    rc = api_call post '/', { rate: 5.75 }.to_json
    rc.should succeed
    rc.body[:rate].should == 5.75
  end

  it 'should accept a float with scientific notation' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :float
      api_params.to_json
    end

    rc = api_call post '/', { rate: 5.75e3 }.to_json
    rc.should succeed
    rc.body[:rate].should == 5.75e3
  end

  it 'should accept a really big decimal' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :float
      api_params.to_json
    end

    rc = api_call post '/', { rate: 123456789.75e24 }.to_json
    rc.should succeed
    rc.body[:rate].should == 123456789.75e24
  end

  it 'should accept an integer' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :float
      api_params.to_json
    end

    rc = api_call post '/', { rate: 5 }.to_json
    rc.should succeed
    rc.body[:rate].should == 5.0
  end

  it 'should reject a non-numeric value' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :float
      api_params.to_json
    end

    rc = api_call post '/', { rate: 'asdf' }.to_json
    rc.should fail(400, 'not a valid float')

    rc = api_call post '/', { rate: [] }.to_json
    rc.should fail(400, 'not a valid float')

    rc = api_call post '/', { rate: {} }.to_json
    rc.should fail(400, 'not a valid float')
  end

  it 'should coerce a float' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :float
      api_params.to_json
    end

    rc = api_call post '/', { rate: "5.8" }.to_json
    rc.should succeed
    rc.body[:rate].should == 5.8
  end

  it 'should not coerce a float' do
    app.post '/' do
      api_parameter! :rate, required: true, type: :float, coerce: false
      api_params.to_json
    end

    rc = api_call post '/', { rate: "15.25" }.to_json
    rc.should succeed
    rc.body[:rate].should == "15.25"
  end
end