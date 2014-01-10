RSpec.configure do |config|
  config.before(:each) do
    Timecop.return
  end
  config.after(:each) do
    Timecop.return
  end
end