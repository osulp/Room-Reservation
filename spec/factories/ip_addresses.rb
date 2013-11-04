# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ip_address do
    ip_address "127.0.0.1"
    auto_login
  end
end
