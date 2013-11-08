RSpec.configure do |config|
  config.before(:each) do
    APP_CONFIG[:keycards].stub(:[]).with(:enabled).and_return(false)
  end
end