describe Sinatra::API::ResourceAliases do
  include_examples 'integration specs'
  include_examples 'aliasing specs'

  context 'processing aliases' do
    before :each do
      app.class_eval do
        Sinatra::API::alias_resource :item, :item_alias
      end
    end

    it 'should export a resource as an alias' do
      app.get '/items/:item_id', requires: [ :item ] do
        @item_alias.to_json
      end

      get '/items/1'
      last_response.status.should == 200
      last_response.body.should == {}.to_json
    end

    it 'should not affect the original resource' do
      app.get '/items/:item_id', requires: [ :item ] do
        @item.to_json
      end

      get '/items/1'
      last_response.status.should == 200
      last_response.body.should == {}.to_json
    end
  end
end