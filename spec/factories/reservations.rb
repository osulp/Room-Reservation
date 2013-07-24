# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reservation do
    user_onid 1
    room_id
    reserver_onid 1
    start_time "2013-07-23"
    end_time "2013-07-23"
    description "MyString"
  end
end
