# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :special_hour, :class => Hours::SpecialHour do
    hours_id 0
    start_date {Time.current.yesterday.midnight}
    end_date {Time.current.midnight}
    open_time "13:00:00"
    close_time "22:00:00"
  end
end
