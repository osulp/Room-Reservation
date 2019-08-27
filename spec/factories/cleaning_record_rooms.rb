# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :cleaning_record_room do
    cleaning_record
    room
  end
end
