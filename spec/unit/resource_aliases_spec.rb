describe Sinatra::API::ResourceAliases do
  include_examples 'aliasing specs'

  describe 'instance methods' do
    context '#alias_resource' do
      it 'should define a resource alias' do
        Sinatra::API.alias_resource :item, :item_alias
        Sinatra::API.resource_aliases[:item].should == [ 'item_alias' ]
      end

      it 'should define multiple resource aliases' do
        Sinatra::API.alias_resource :item, :first_alias
        Sinatra::API.alias_resource :item, :second_alias
        Sinatra::API.resource_aliases[:item].should == %w[ first_alias second_alias ]
      end

      it 'should ignore duplicate aliases' do
        Sinatra::API.alias_resource :item, :item_alias
        Sinatra::API.alias_resource :item, :item_alias
        Sinatra::API.resource_aliases[:item].should == [ 'item_alias' ]
      end

      it 'should ignore a meaningless alias' do
        Sinatra::API.alias_resource :item, :item
        Sinatra::API.resource_aliases[:item].should == []
      end
    end

    context '#aliases_for' do
      it 'should locate a resource alias' do
        Sinatra::API.alias_resource :item, :item_alias
        Sinatra::API.aliases_for(:item).should == [ 'item_alias' ]
      end
    end
  end

  context 'processing aliases' do
    it 'should export a resource as an alias' do
      Sinatra::API.alias_resource :item, :item_alias
      Sinatra::API.trigger(:resource_located, Item.new, 'item')
    end
  end
end