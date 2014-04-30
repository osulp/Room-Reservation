require 'rspec/core'
Spring.watch "#{File.expand_path File.dirname(__FILE__)}/../spec/factories"
Spring.watch "#{File.expand_path File.dirname(__FILE__)}/../spec/spec_helper.rb"
Spring.after_fork do
  if Rails.env == 'test'
    RSpec.configure do |config|
      srand; config.seed = srand % 0xFFFF
    end
  end
end
