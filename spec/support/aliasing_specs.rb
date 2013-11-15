shared_examples_for 'aliasing specs' do
  before :each do
    Sinatra::API.reset_aliases!

    app.class_eval do
      Sinatra::API.reset_aliases!
    end
  end
end