# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :hour, :class => Hours::Hour do
    loc "The Valley Library"
    open_time_1 "12:00 am"
    close_time_1 "12:00 am"
    open_time_5 "12:15 am"
    close_time_5 "10:00 pm"
    open_time_6 "10:00 am"
    close_time_6 "10:00 pm"
    open_time_7 "10:00 am"
    close_time_7 "12:15 am"
    term "Spring"
    term_start_date Date.yesterday
    term_end_date Date.today+90.days
  end
end
