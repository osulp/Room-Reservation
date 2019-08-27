# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :reservation do
    sequence(:user_onid) {|n| "reservation_user#{n}"}
    room
    sequence(:reserver_onid) {|n| "user#{n}"}
    start_time {Time.now}
    end_time {Time.now}
    description "MyString"
  end
end
