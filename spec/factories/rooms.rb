# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :room do
    sequence(:name) {|n| "Room #{n}"}
    sequence(:floor) {|n| n}
  end
end
