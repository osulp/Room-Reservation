require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  begin
    FactoryBot.find_definitions
  rescue
  end
end
