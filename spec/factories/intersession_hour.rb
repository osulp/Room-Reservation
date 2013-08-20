# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :intersession_hour do
    start_date Date.yesterday
    end_date Date.today+10.days
    open_time_wk '07:30:00'
    open_time_sat '01:00:00'
    open_time_sun '13:00:00'
    close_time_wk '18:00:00'
    close_time_sat '01:00:00'
    close_time_sun '18:00:00'
    hours_id 0
  end
end
