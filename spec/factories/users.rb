# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    ignore do
      sequence(:onid) {|n| "User#{n}"}
    end
    trait :admin do
      after(:build) do |user|
        result = FactoryGirl.create(:role, :role => :admin, :onid => user.onid)
      end
    end
    trait :staff do
      after(:build) do |user|
        FactoryGirl.create(:role, :role => :staff, :onid => user.onid)
      end
    end
    initialize_with {User.new(onid)}
  end
end
