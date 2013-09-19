describe "Helpers" do
  before :each do
    Router.purge('/')
  end

  class ModelAdapter
  end

  class CollectionAdapter
    def initialize(model)
      @model = model
    end

    def self.get(key)
      return @model.new
    end
  end

  class Item
    def self.get(id)
      return {} if id == 1
    end

    def sub_items
      CollectionAdapter.new(SubItem)
    end
  end

  class SubItem < ModelAdapter
    def item
      Item.new
    end
  end

  it "should reject a request missing a required parameter" do
    app.get '/' do
      api_required!({
        id: nil
      })
    end

    get '/'
    last_response.status.should == 400
    last_response.body.should match(/Missing required parameter :id/)
  end

  it "should accept a request satisfying required parameters" do
    app.get '/' do
      api_required!({
        id: nil
      })
    end

    get '/', { id: 5 }
    last_response.status.should == 200
  end

  it "should accept a request not satisfying optional parameters" do
    app.get '/' do
      api_required!({
        id: nil
      })
      api_optional!({
        name: nil
      })
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

  it "should locate a resource" do
    app.get '/items/:item_id', requires: [ :item ] do
      @item.to_json
    end

    get '/items/1'
    last_response.status.should == 200
    last_response.body.should == {}.to_json

    get '/items/2'
    last_response.status.should == 404
    last_response.body.should match /No such resource/
  end

  it "should define a resource alias" do
    Sinatra::API.alias_resource :item, :item_alias
    Sinatra::API.aliases_for(:item).should == [ 'item_alias' ]
  end
end