class RoomHour < ActiveRecord::Base
  attr_accessible :end_date, :end_time, :start_date, :start_time
  validates :start_date, :end_date, :start_time, :end_time, :presence => true
  validate :start_date_correct
  validate :start_time_correct
  has_many :room_hour_records
  has_many :rooms, :through => :room_hour_records

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

end
