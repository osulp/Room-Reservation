# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :banner_record do
    onid "User"
    status "Undergraduate"
    email "test@test.org"
    fullName "Senor Test"
    idHash "931590201"
  end
end
