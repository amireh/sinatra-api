shared_examples_for "integration specs" do
  before :each do
    Router.purge('/')

    header 'Content-Type', 'application/json'
    header 'Accept', 'application/json'
  end
end