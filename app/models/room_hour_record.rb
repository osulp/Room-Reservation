class RoomHourRecord < ActiveRecord::Base
  belongs_to :room
  belongs_to :room_hour, :touch => true

  after_create :expire_presenter

  protected

  def expire_presenter
    start_date = room_hour.start_date
    end_date = room_hour.end_date
    start_date.upto(end_date) do |date|
      time = Time.zone.parse(date.to_s)
      CalendarPresenter.expire_time(time, time.tomorrow.midnight)
    end
  end
end
