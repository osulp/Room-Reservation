RSpec.configure do |config|
  config.after(:each) do
    RubyCAS::Filter.fake(nil)
  end
end