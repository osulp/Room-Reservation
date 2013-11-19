# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :key_card do
    sequence(:key) {|n| 12345600000+n}
    room
    factory:key_card_checked_out do
      reservation
      room {reservation.room}
    end
  end
end
