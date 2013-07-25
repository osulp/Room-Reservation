# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reservation do
    user_onid 1
    room
    reserver_onid 1
    start_time Time.now
    end_time Time.now
    description "MyString"
  end
end
