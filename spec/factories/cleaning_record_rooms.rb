# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cleaning_record_room do
    cleaning_record
    room
  end
end
