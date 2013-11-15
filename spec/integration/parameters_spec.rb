describe Sinatra::API::Parameters do
  include_examples 'integration specs'

  context 'defining parameters' do
    context 'required parameters' do
      it 'should define a required parameter using hash style' do
        app.get '/' do
          api_required!({
            id: nil
          })
        end

        get '/'
        last_response.status.should == 400
        last_response.body.should match(/Missing required parameter :id/)
      end

      it 'should define required parameters using list style' do
        app.post '/' do
          api_required!([ :id, :name ])
        end

        post '/'
        last_response.status.should == 400
        last_response.body.should match(/missing required parameter :id/i)

        post '/', { id: 10 }.to_json
        last_response.status.should == 400
        last_response.body.should match(/missing required parameter :name/i)
      end

      it 'should define a single required parameter' do
        app.get '/' do
          api_parameter! :id, required: true
        end

        get '/'
        last_response.status.should == 400
        last_response.body.should match(/Missing required parameter :id/)
      end
    end

    context 'optional parameters' do
      it 'should define an optional parameter using hash style' do
        app.get '/' do
          api_optional!({
            id: nil
          })
        end

        get '/'
        last_response.status.should == 200
      end

      it 'should define a single required parameter' do
        app.get '/' do
          api_parameter! :id
        end

        get '/'
        last_response.status.should == 200
      end

      it 'should define optional parameters using list style' do
        app.post '/' do
          api_optional! [ :id, :name ]
          api_params.to_json
        end

        post '/', { id: 5, name: 'test' }.to_json
        last_response.status.should == 200
        last_response.body.should == { id: 5, name: 'test' }.to_json
      end
    end
  end

  it "should reject a request missing a required parameter" do
    app.get '/' do
      api_required! [ :id ]
    end

    get '/'
    last_response.status.should == 400
    last_response.body.should match(/Missing required parameter :id/)
  end

  it "should accept a request satisfying required parameters" do
    app.get '/' do
      api_required! [ :id ]
    end

    get '/', { id: 5 }
    last_response.status.should == 200
  end

  it "should accept a request not satisfying optional parameters" do
    app.get '/' do
      api_required! [ :id ]
      api_optional! [ :name ]
    end

    get '/', { id: 5 }
    last_response.status.should == 200
  end

  it "should apply parameter conditions" do
    app.get '/' do
      api_optional!({
        name: lambda { |v|
          unless (v || '').match /ahmad/
            "Unexpected name."
          end
        }
      })
    end

    get '/', { name: 'foobar' }
    last_response.status.should == 400
    last_response.body.should match(/Unexpected name/)

    get '/', { name: 'ahmad' }
    last_response.status.should == 200
  end

  it "should pick parameters" do
    app.get '/' do
      api_optional!({
        name: nil
      })

      api_params.to_json
    end

    get '/', {
      name: 'foobar',
      some: 'thing'
    }

    last_response.body.should == {
      name: 'foobar'
    }.to_json
  end

end