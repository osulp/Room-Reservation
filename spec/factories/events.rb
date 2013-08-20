FactoryGirl.define do
  factory :event do
    ignore do
      start_time {Time.current.midnight}
      end_time {Time.current.midnight+2.hours}
      priority 0
      object nil
    end
    initialize_with { new(start_time, end_time, priority, object) }
  end
end
