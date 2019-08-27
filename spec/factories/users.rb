# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user do
    ignore do
      sequence(:onid) {|n| "User#{n}"}
    end
    trait :admin do
      after(:build) do |user|
        result = FactoryBot.create(:role, :role => :admin, :onid => user.onid)
      end
    end
    trait :staff do
      after(:build) do |user|
        FactoryBot.create(:role, :role => :staff, :onid => user.onid)
      end
    end
    initialize_with {User.new(onid)}
  end
end
