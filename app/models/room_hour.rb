class RoomHour < ActiveRecord::Base
  attr_accessible :end_date, :end_time, :start_date, :start_time
  validates :start_date, :end_date, :start_time, :end_time, :presence => true
  validate :start_date_correct
  validate :start_time_correct
  has_many :room_hour_records
  has_many :rooms, :through => :room_hour_records

  after_save :expire_presenter
  after_destroy :expire_presenter

  protected

  def start_date_correct
    if start_date && end_date && start_date > end_date
      errors.add(:start_date, "must be before the end date.")
    end
  end

  def start_time_correct
    if start_time && end_time && start_time > end_time
      errors.add(:start_time, "must be before the end time.")
    end
  end

  # TODO: MAKE THIS BETTER
  # Right now this is required because cache keys use updated_at, and MySQL only stores updated_at to the second.
  # This can make saving a room hour that affects a large date range take a LONG time.

  def expire_presenter
    start_date = self.start_date
    end_date = self.end_date
    start_date.upto(end_date) do |date|
      time = Time.zone.parse(date.to_s)
      CalendarPresenter.expire_time(time, time.tomorrow.midnight)
    end
  end

end
