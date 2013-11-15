describe Sinatra::API::Resources do
  include_examples 'integration specs'

  it 'should locate a resource' do
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
end