class CleaningRecordDecorator < Draper::Decorator
  delegate_all

  def date_range
    "#{start_date.strftime("%m/%d")} - #{end_date.strftime("%m/%d")}"
  end

  def time_range
    "#{start_time.utc.strftime("%l:%M %p")} - #{end_time.utc.strftime("%l:%M %p")}"
  end
end
